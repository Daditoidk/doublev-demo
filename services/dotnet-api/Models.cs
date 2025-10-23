using Microsoft.EntityFrameworkCore;
using System.Text.Json.Serialization;

public class UserProfile
{
    public int Id { get; set; }
    public string FirstName { get; set; } = "";
    public string LastName { get; set; } = "";
    public DateTime? BirthDate { get; set; }
    public List<Address> Addresses { get; set; } = [];
}

public class Address
{
    public int Id { get; set; }
    public string Line1 { get; set; } = "";
    public string? Line2 { get; set; }
    public string CountryCode { get; set; } = "";
    public string DepartmentCode { get; set; } = "";
    public string MunicipalityCode { get; set; } = "";

    public double? Latitude { get; set; }
    public double? Longitude { get; set; }

    public int UserProfileId { get; set; }

    [JsonIgnore] // prevents Address -> UserProfile -> Addresses -> ...
    public UserProfile? UserProfile { get; set; }
}


public class Country
{
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
}

public class Department
{
    public string Code { get; set; } = "";
    public string CountryCode { get; set; } = "";
    public string Name { get; set; } = "";
}

public class Municipality
{
    public string Code { get; set; } = "";
    public string DepartmentCode { get; set; } = "";
    public string Name { get; set; } = "";
}
