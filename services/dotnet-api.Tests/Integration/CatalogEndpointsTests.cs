using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Xunit;
using dotnet_api.Tests.Helpers;

namespace dotnet_api.Tests.Integration;

public class CatalogEndpointsTests : IClassFixture<TestWebApplicationFactory>
{
    private readonly HttpClient _client;

    public CatalogEndpointsTests(TestWebApplicationFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetCountries_ReturnsOkWithCountries()
    {
        // Act
        var response = await _client.GetAsync("/catalog/countries");
        var countries = await response.Content.ReadFromJsonAsync<List<Country>>();

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        countries.Should().NotBeNull();
        countries.Should().Contain(c => c.Code == "CO");
    }

    [Fact]
    public async Task GetDepartments_WithValidCountryCode_ReturnsDepartments()
    {
        // Act
        var response = await _client.GetAsync("/catalog/departments?countryCode=CO");
        var departments = await response.Content.ReadFromJsonAsync<List<Department>>();

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        departments.Should().NotBeNull();
        departments.Should().Contain(d => d.Code == "CUN");
    }

    [Fact]
    public async Task GetMunicipalities_WithValidDepartmentCode_ReturnsMunicipalities()
    {
        // Act
        var response = await _client.GetAsync("/catalog/municipalities?departmentCode=CUN");
        var municipalities = await response.Content.ReadFromJsonAsync<List<Municipality>>();

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        municipalities.Should().NotBeNull();
        municipalities.Should().Contain(m => m.Code == "BOG");
    }
}