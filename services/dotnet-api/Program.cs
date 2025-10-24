using Microsoft.EntityFrameworkCore;
using System.Text.Json.Serialization;
using AutoMapper;
using System.Globalization;
using System.Text.RegularExpressions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAutoMapper(typeof(MappingProfile));
// DB SQLite
builder.Services.AddDbContext<AppDb>(opt =>
    opt.UseSqlite("Data Source=app.db"));

// CORS for Flutter web/local (adjust ports)
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
    // Works in InMemory and SQL
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

app.MapPut("/users/{id:int}", async (AppDb db, IMapper mapper, IHttpClientFactory httpFactory, int id, UserDto dto) =>
{
    var entity = await db.Users
        .Include(u => u.Addresses)
        .FirstOrDefaultAsync(u => u.Id == id);

    if (entity is null) return Results.NotFound();

    // Map ONLY scalar fields (addresses ignored by profile)
    mapper.Map(dto, entity);

    // Remove old addresses
    var toDelete = entity.Addresses.ToList();
    db.Addresses.RemoveRange(toDelete);

    // Map new addresses and geocode if needed
    var incoming = dto.Addresses ?? new List<AddressDto>();
    var newAddresses = mapper.Map<List<Address>>(incoming);

    foreach (var address in newAddresses)
    {
        // Geocode if coordinates are missing
        if (address.Latitude == null || address.Longitude == null)
        {
            var municipality = await db.Municipalities
                .FirstOrDefaultAsync(m => m.Code == address.MunicipalityCode);

            if (municipality != null)
            {
                var rawQuery = $"{address.Line1}, {municipality.Name}, Colombia";
                var query = CleanAddress(rawQuery);
                var coords = await GeocodeAddress(httpFactory, query);

                if (coords != null)
                {
                    address.Latitude = coords.Value.lat;
                    address.Longitude = coords.Value.lon;
                }
            }

            // Delay to respect rate limit
            await Task.Delay(1500);
        }
    }

    entity.Addresses = newAddresses;
    await db.SaveChangesAsync();

    return Results.Ok(mapper.Map<UserDto>(entity));
});

app.MapPost("/users", async (AppDb db, IMapper mapper, IHttpClientFactory httpFactory, UserDto dto) =>
{
    // Map scalar fields only (AutoMapper ignores Addresses collection)
    var entity = mapper.Map<UserProfile>(dto);

    // Map addresses separately
    var addressDtos = dto.Addresses ?? new List<AddressDto>();
    var addresses = mapper.Map<List<Address>>(addressDtos);

    // Geocode each address if coordinates are missing
    foreach (var address in addresses)
    {
        if (address.Latitude == null || address.Longitude == null)
        {
            // Get municipality name for better geocoding
            var municipality = await db.Municipalities
                .FirstOrDefaultAsync(m => m.Code == address.MunicipalityCode);

            if (municipality != null)
            {
                var rawQuery = $"{address.Line1}, {municipality.Name}, Colombia";
                var query = CleanAddress(rawQuery);
                Console.WriteLine($"🌍 Geocoding: {query}");

                var coords = await GeocodeAddress(httpFactory, query);

                if (coords != null)
                {
                    address.Latitude = coords.Value.lat;
                    address.Longitude = coords.Value.lon;
                    Console.WriteLine($"✅ Coordinates: lat={coords.Value.lat}, lon={coords.Value.lon}");
                }
                else
                {
                    Console.WriteLine($"⚠️ Could not geocode: {query}");
                }
            }

            // Delay to respect Nominatim rate limit (max 1 req/sec)
            await Task.Delay(1500);
        }
    }

    // Assign geocoded addresses to entity
    entity.Addresses = addresses;

    db.Users.Add(entity);
    await db.SaveChangesAsync();

    var outDto = mapper.Map<UserDto>(entity);
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
    var coords = await GeocodeAddress(f, q);
    if (coords == null) return Results.NotFound();
    return Results.Ok(new { lat = coords.Value.lat, lon = coords.Value.lon });
});

// Helper method for geocoding
async Task<(double lat, double lon)?> GeocodeAddress(IHttpClientFactory factory, string query)
{
    var http = factory.CreateClient();
    var url = $"https://nominatim.openstreetmap.org/search" +
             $"?format=json&limit=1&addressdetails=1&extratags=1&countrycodes=co&q={Uri.EscapeDataString(query)}";
    var req = new HttpRequestMessage(HttpMethod.Get, url);
    req.Headers.UserAgent.ParseAdd("DoubleVDemo/1.0 (cam@dev.com)");

    try
    {
        var res = await http.SendAsync(req);
        if (!res.IsSuccessStatusCode)
        {
            Console.WriteLine($"❌ Geocoding failed: {res.StatusCode}");
            return null;
        }

        var parsed = await res.Content.ReadFromJsonAsync<List<NominatimResult>>() ?? new();
        if (parsed.Count == 0)
        {
            Console.WriteLine($"❌ No results found for: {query}");
            return null;
        }

        var p = parsed[0];
        var lat = double.Parse(p.lat, CultureInfo.InvariantCulture);
        var lon = double.Parse(p.lon, CultureInfo.InvariantCulture);
        return (lat, lon);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Geocoding exception: {ex.Message}");
        return null;
    }
}

static string CleanAddress(string query)
{
    if (string.IsNullOrWhiteSpace(query))
        return string.Empty;

    var q = query.Trim();

    // Replace common abbreviations with full forms (helps Nominatim)
    q = Regex.Replace(q, @"\bCra\.?\b", "Carrera", RegexOptions.IgnoreCase);
    q = Regex.Replace(q, @"\bCl\.?\b", "Calle", RegexOptions.IgnoreCase);
    q = Regex.Replace(q, @"\bAv\.?\b", "Avenida", RegexOptions.IgnoreCase);
    q = Regex.Replace(q, @"\bNo\.?\b", "", RegexOptions.IgnoreCase);
    q = Regex.Replace(q, @"\bNº\b", "", RegexOptions.IgnoreCase);
    q = Regex.Replace(q, "#", " ", RegexOptions.IgnoreCase);

    // Remove double spaces or trailing punctuation
    q = Regex.Replace(q, @"[^\w\s,]", " ");
    q = Regex.Replace(q, @"\s{2,}", " ").Trim(' ', ',');

    return q;
}


app.Run();

// To run tests
public partial class Program { }