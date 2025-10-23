public record AddressDto(
    int? Id,
    string Line1,
    string? Line2,
    string CountryCode,
    string DepartmentCode,
    string MunicipalityCode,
    double? Latitude,
    double? Longitude
);
public record UserDto(
    int? Id,
    string FirstName,
    string LastName,
    DateTime? BirthDate,
    List<AddressDto> Addresses);

public record NominatimResult(string lat, string lon);