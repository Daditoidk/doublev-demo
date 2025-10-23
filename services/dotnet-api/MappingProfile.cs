using AutoMapper;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // DTO -> Entity
        CreateMap<UserDto, UserProfile>()
            .ForMember(d => d.Id, o => o.Ignore())
            .ForMember(d => d.Addresses, o => o.Ignore()); // ⬅️ IMPORTANT: don't map collection here

        CreateMap<AddressDto, Address>()
            .ForMember(d => d.Id, o => o.Ignore())
            .ForMember(d => d.UserProfile, o => o.Ignore())
            .ForMember(d => d.UserProfileId, o => o.Ignore());

        // Entity -> DTO
        CreateMap<UserProfile, UserDto>();
        CreateMap<Address, AddressDto>();
    }
}
