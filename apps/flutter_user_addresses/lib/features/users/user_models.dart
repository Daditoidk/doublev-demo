
class UserDto {
  final int? id;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final List<AddressDto> addresses;

  UserDto({
    this.id,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    required this.addresses,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int?,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      addresses: (json['addresses'] as List<dynamic>? ?? [])
          .map((a) => AddressDto.fromJson(a))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate?.toIso8601String(),
        'addresses': addresses.map((a) => a.toJson()).toList(),
      };

  UserDto copyWith({
    int? id,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    List<AddressDto>? addresses,
  }) {
    return UserDto(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      addresses: addresses ?? this.addresses,
    );
  }
}

class AddressDto {
  final int? id;
  final String? line1;
  final String? line2;
  final String? countryCode;
  final String? departmentCode;
  final String? municipalityCode;
  final double? latitude;
  final double? longitude;

  AddressDto({
    this.id,
    this.line1,
    this.line2,
    this.countryCode,
    this.departmentCode,
    this.municipalityCode,
    this.latitude,
    this.longitude,
  });

  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      id: json['id'] as int?,
      line1: json['line1'],
      line2: json['line2'],
      countryCode: json['countryCode'],
      departmentCode: json['departmentCode'],
      municipalityCode: json['municipalityCode'],
      latitude: (json['latitude'] != null)
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: (json['longitude'] != null)
          ? (json['longitude'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'line1': line1,
        'line2': line2,
        'countryCode': countryCode,
        'departmentCode': departmentCode,
        'municipalityCode': municipalityCode,
        'latitude': latitude,
        'longitude': longitude,
      };

  AddressDto copyWith({
    int? id,
    String? line1,
    String? line2,
    String? countryCode,
    String? departmentCode,
    String? municipalityCode,
    double? latitude,
    double? longitude,
  }) {
    return AddressDto(
      id: id ?? this.id,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      countryCode: countryCode ?? this.countryCode,
      departmentCode: departmentCode ?? this.departmentCode,
      municipalityCode: municipalityCode ?? this.municipalityCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
