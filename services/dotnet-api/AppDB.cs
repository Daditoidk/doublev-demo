using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using System.IO;               // for File.*
using System.Linq;             // for Any()
using System.Collections.Generic; // for List<>
using Microsoft.EntityFrameworkCore.Design;




public static class SeedLoader
{
    public static void SeedFromJson(AppDb db, string path)
    {
        if (!File.Exists(path)) return;
        var json = File.ReadAllText(path);
        var data = JsonSerializer.Deserialize<LocationSeed>(json);
        if (data is null) return;

        if (!db.Countries.Any(c => c.Code == data.Country.Code))
            db.Countries.Add(new Country { Code = data.Country.Code, Name = data.Country.Name });

        foreach (var d in data.Departments)
        {
            if (!db.Departments.Any(x => x.Code == d.Code))
                db.Departments.Add(new Department { Code = d.Code, CountryCode = data.Country.Code, Name = d.Name });

            foreach (var m in d.Municipalities)
            {
                if (!db.Municipalities.Any(x => x.Code == m.Code))
                    db.Municipalities.Add(new Municipality { Code = m.Code, DepartmentCode = d.Code, Name = m.Name });
            }
        }

        db.SaveChanges();
    }

    // DTOs para deserializar
    public class LocationSeed
    {
        public CountryDto Country { get; set; } = new();
        public List<DeptDto> Departments { get; set; } = new();
        public class CountryDto { public string Code { get; set; } = ""; public string Name { get; set; } = ""; }
        public class DeptDto
        {
            public string Code { get; set; } = "";
            public string Name { get; set; } = "";
            public List<CityDto> Municipalities { get; set; } = new();
        }
        public class CityDto { public string Code { get; set; } = ""; public string Name { get; set; } = ""; }
    }
}


public class AppDbFactory : IDesignTimeDbContextFactory<AppDb>
{
    public AppDb CreateDbContext(string[] args)
    {
        var opts = new DbContextOptionsBuilder<AppDb>()
            .UseSqlite("Data Source=app.db")
            .Options;
        return new AppDb(opts);
    }
}

public class AppDb : DbContext
{
    public AppDb(DbContextOptions<AppDb> options) : base(options) { }

    public DbSet<UserProfile> Users => Set<UserProfile>();
    public DbSet<Address> Addresses => Set<Address>();
    public DbSet<Country> Countries => Set<Country>();
    public DbSet<Department> Departments => Set<Department>();
    public DbSet<Municipality> Municipalities => Set<Municipality>();

    protected override void OnModelCreating(ModelBuilder m)
    {
        // User ↔ Address
        m.Entity<UserProfile>()
            .HasMany(u => u.Addresses)
            .WithOne(a => a.UserProfile!)
            .HasForeignKey(a => a.UserProfileId)
            .OnDelete(DeleteBehavior.Cascade);

        // Catalog PKs
        m.Entity<Country>().HasKey(c => c.Code);
        m.Entity<Department>().HasKey(d => d.Code);
        m.Entity<Municipality>().HasKey(mm => mm.Code);

        // Catalog FKs
        m.Entity<Department>()
            .HasOne<Country>()
            .WithMany()
            .HasForeignKey(d => d.CountryCode)
            .OnDelete(DeleteBehavior.Restrict);

        m.Entity<Municipality>()
            .HasOne<Department>()
            .WithMany()
            .HasForeignKey(mm => mm.DepartmentCode)
            .OnDelete(DeleteBehavior.Restrict);

    }
}
