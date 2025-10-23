using Microsoft.EntityFrameworkCore;
using System.Text.Json.Serialization;
using AutoMapper;
using System.Globalization;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAutoMapper(typeof(MappingProfile));
// DB SQLite
builder.Services.AddDbContext<AppDb>(opt =>
    opt.UseSqlite("Data Source=app.db"));

// CORS  for Flutter web/local (adjust ports)
builder.Services.AddCors(o => o.AddDefaultPolicy(p =>
    p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

//ignore cycles in JSON
builder.Services.ConfigureHttpJsonOptions(opt =>
{
    opt.SerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
    opt.SerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
});

var app = builder.Build();

app.UseCors();
app.UseSwagger();
app.UseSwaggerUI();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDb>();
    // Worsk inInMemory and SQL
    if (db.Database.IsRelational()) db.Database.Migrate();
    else db.Database.EnsureCreated();
    

    if (!app.Environment.IsEnvironment("Testing"))
    {
        var seedPath = Path.Combine(AppContext.BaseDirectory, "Locations", "locations.co.json");
        if (File.Exists(seedPath) && !db.Countries.Any())
        {
            SeedLoader.SeedFromJson(db, seedPath);
        }
    }
}

// ---- Catalogs
app.MapGet("/catalog/countries", async (AppDb db) =>
    await db.Countries.OrderBy(c => c.Name).ToListAsync());

app.MapGet("/catalog/departments", async (AppDb db, string countryCode) =>
    await db.Departments.Where(d => d.CountryCode == countryCode)
                        .OrderBy(d => d.Name).ToListAsync());

app.MapGet("/catalog/municipalities", async (AppDb db, string departmentCode) =>
    await db.Municipalities.Where(m => m.DepartmentCode == departmentCode)
                           .OrderBy(m => m.Name).ToListAsync());

// ---- Users CRUD
app.MapGet("/users", async (AppDb db, IMapper mapper) =>
{
    var users = await db.Users
        .Include(u => u.Addresses)
        .AsNoTracking()
        .ToListAsync();

    return Results.Ok(mapper.Map<List<UserDto>>(users));
});

app.MapGet("/users/{id:int}", async (AppDb db, IMapper mapper, int id) =>
{
    var u = await db.Users
        .Include(x => x.Addresses)
        .AsNoTracking()
        .FirstOrDefaultAsync(x => x.Id == id);

    return u is null ? Results.NotFound()
                     : Results.Ok(mapper.Map<UserDto>(u));
});

app.MapPut("/users/{id:int}", async (AppDb db, IMapper mapper, int id, UserDto dto) =>
{
    var entity = await db.Users
        .Include(u => u.Addresses)
        .FirstOrDefaultAsync(u => u.Id == id);

    if (entity is null) return Results.NotFound();

    // Map ONLY scalar fields (addresses ignored by profile)
    mapper.Map(dto, entity);

    // Copy old addresses BEFORE changing the collection
    var incoming = dto.Addresses ?? new List<AddressDto>(); // guard
    var toDelete = entity.Addresses.ToList();       // ⬅ snapshot
    db.Addresses.RemoveRange(toDelete);             // delete persisted ones

    // Assign fresh addresses from DTO
    var newAddresses = mapper.Map<List<Address>>(incoming);
    entity.Addresses = newAddresses;

    await db.SaveChangesAsync();

    return Results.Ok(mapper.Map<UserDto>(entity));
});


app.MapPost("/users", async (AppDb db, IMapper mapper, UserDto dto) =>
{
    var entity = mapper.Map<UserProfile>(dto);        // DTO -> Entity
    db.Users.Add(entity);
    await db.SaveChangesAsync();

    var outDto = mapper.Map<UserDto>(entity);         // Entity -> DTO
    return Results.Created($"/users/{entity.Id}", outDto);
});




app.MapDelete("/users/{id:int}", async (AppDb db, int id) =>
{
    var entity = await db.Users.FindAsync(id);
    if (entity is null) return Results.NotFound();
    db.Users.Remove(entity);
    await db.SaveChangesAsync();
    return Results.NoContent();
});


app.MapGet("/geocode", async (IHttpClientFactory f, string q) =>
{
    var http = f.CreateClient();
    var url = $"https://nominatim.openstreetmap.org/search" +
             $"?format=json&limit=1&addressdetails=1&extratags=1&countrycodes=co&q={Uri.EscapeDataString(q)}";
    var req = new HttpRequestMessage(HttpMethod.Get, url);
    req.Headers.UserAgent.ParseAdd("DoubleVDemo/1.0 (cam@dev.com)");
    var res = await http.SendAsync(req);
    if (!res.IsSuccessStatusCode) return Results.Problem("Geocoding failed");
    var parsed = await res.Content.ReadFromJsonAsync<List<NominatimResult>>() ?? new();
    if (parsed.Count == 0) return Results.NotFound();
    var p = parsed[0];
    var lat = double.Parse(p.lat, CultureInfo.InvariantCulture);
    var lon = double.Parse(p.lon, CultureInfo.InvariantCulture);
    return Results.Ok(new { lat, lon });
});

app.Run();


//To run tests
public partial class Program { }