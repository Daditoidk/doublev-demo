using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Xunit;
using dotnet_api.Tests.Helpers;

namespace dotnet_api.Tests.Integration;

public class UsersEndpointsTests : IClassFixture<TestWebApplicationFactory>
{
    private readonly HttpClient _client;

    public UsersEndpointsTests(TestWebApplicationFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetUsers_ReturnsOkWithUsers()
    {
        // Act
        var response = await _client.GetAsync("/users");
        var users = await response.Content.ReadFromJsonAsync<List<UserDto>>();

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        users.Should().NotBeNull();
        users.Should().HaveCountGreaterThan(0);
    }

    [Fact]
    public async Task GetUserById_WithValidId_ReturnsUser()
    {
        // Arrange
        var userId = 1;

        // Act
        var response = await _client.GetAsync($"/users/{userId}");
        var user = await response.Content.ReadFromJsonAsync<UserDto>();

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        user.Should().NotBeNull();
        user!.Id.Should().Be(userId);
    }

    [Fact]
    public async Task CreateUser_WithValidData_ReturnsCreated()
    {
        // Arrange
        var newUser = new UserDto(
            Id: null,
            FirstName: "Juan",
            LastName: "Pérez",
            BirthDate: new DateTime(1995, 5, 15),
            Addresses: new List<AddressDto>()
        );

        // Act
        var response = await _client.PostAsJsonAsync("/users", newUser);
        var createdUser = await response.Content.ReadFromJsonAsync<UserDto>();

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        createdUser.Should().NotBeNull();
        createdUser!.FirstName.Should().Be("Juan");
    }

    [Fact]
    public async Task UpdateUser_WithValidData_ReturnsOk()
    {
        // Arrange
        var userId = 1;
        var updatedUser = new UserDto(
            Id: userId,
            FirstName: "Updated",
            LastName: "Name",
            BirthDate: new DateTime(1990, 1, 1),
            Addresses: new List<AddressDto>
            {
            new AddressDto(
                Id: null,
                Line1: "New Address",
                Line2: null,
                CountryCode: "CO",
                DepartmentCode: "CUN",
                MunicipalityCode: "BOG",
                Latitude: 4.7110,
                Longitude: -74.0721
            )
            }
        );

        // Act
        var response = await _client.PutAsJsonAsync($"/users/{userId}", updatedUser);
        var result = await response.Content.ReadFromJsonAsync<UserDto>();

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        result!.FirstName.Should().Be("Updated");
    }

    [Fact]
    public async Task DeleteUser_WithValidId_ReturnsNoContent()
    {
        // Arrange - Crear usuario para eliminar
        var newUser = new UserDto(null, "ToDelete", "User", null, new List<AddressDto>());
        var createResponse = await _client.PostAsJsonAsync("/users", newUser);
        var created = await createResponse.Content.ReadFromJsonAsync<UserDto>();

        // Act
        var deleteResponse = await _client.DeleteAsync($"/users/{created!.Id}");

        // Assert
        deleteResponse.StatusCode.Should().Be(HttpStatusCode.NoContent);
    }

    [Fact]
    public async Task GetUserById_WithInvalidId_ReturnsNotFound()
    {
        // Act
        var response = await _client.GetAsync("/users/999");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

}