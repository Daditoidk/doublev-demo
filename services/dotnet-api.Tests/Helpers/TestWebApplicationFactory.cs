using System.Linq;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace dotnet_api.Tests.Helpers;

public class TestWebApplicationFactory : WebApplicationFactory<Program>
{
    private SqliteConnection? _conn;

    protected override IHost CreateHost(IHostBuilder builder)
    {
        builder.UseEnvironment("Testing");

        builder.ConfigureServices(services =>
        {
            // Remove the real AppDb registration (SQLite file)
            var descriptor = services.Single(d => d.ServiceType == typeof(DbContextOptions<AppDb>));
            services.Remove(descriptor);

            // Single shared in-memory SQLite connection for the whole test host
            _conn = new SqliteConnection("DataSource=:memory:");
            _conn.Open();

            services.AddDbContext<AppDb>(opt => opt.UseSqlite(_conn));
        });

        // Build the host first
        var host = base.CreateHost(builder);

        // NOW seed using the same provider the app will use
        using var scope = host.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDb>();

        // Create schema
        db.Database.EnsureCreated();

        // Seed ONLY here (do NOT also seed in Program.cs during Testing)
        SeedTestData(db);

        return host;
    }

    private static void SeedTestData(AppDb db)
    {
        // Avoid duplicates if a test reuses factory
        if (!db.Countries.Any())
        {
            db.Countries.Add(new Country { Code = "CO", Name = "Colombia" });
            db.Departments.Add(new Department { Code = "CUN", CountryCode = "CO", Name = "Cundinamarca" });
            db.Municipalities.AddRange(
                new Municipality { Code = "BOG", DepartmentCode = "CUN", Name = "Bogotá" },
                new Municipality { Code = "FUN", DepartmentCode = "CUN", Name = "Funza" }
            );
        }

        if (!db.Users.Any())
        {
            db.Users.Add(new UserProfile
            {
                FirstName = "Alice",
                LastName = "Tester",
                BirthDate = new DateTime(2000, 1, 1),
                Addresses = new List<Address>
                {
                    new Address
                    {
                        Line1 = "Cra 1 #2-3",
                        CountryCode = "CO",
                        DepartmentCode = "CUN",
                        MunicipalityCode = "BOG",
                        Latitude = 4.711,
                        Longitude = -74.072
                    }
                }
            });
        }

        db.SaveChanges();
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        _conn?.Dispose(); // keep connection open during host lifetime, then dispose
    }
}
