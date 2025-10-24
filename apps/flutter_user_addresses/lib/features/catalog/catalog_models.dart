class Country {
  final String code;
  final String name;

  Country({required this.code, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) =>
      Country(code: json['code'], name: json['name']);

  Map<String, dynamic> toJson() => {'code': code, 'name': name};
}

class Department {
  final String code;
  final String countryCode;
  final String name;

  Department({
    required this.code,
    required this.countryCode,
    required this.name,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        code: json['code'],
        countryCode: json['countryCode'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() =>
      {'code': code, 'countryCode': countryCode, 'name': name};
}

class Municipality {
  final String code;
  final String departmentCode;
  final String name;

  Municipality({
    required this.code,
    required this.departmentCode,
    required this.name,
  });

  factory Municipality.fromJson(Map<String, dynamic> json) => Municipality(
        code: json['code'],
        departmentCode: json['departmentCode'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() =>
      {'code': code, 'departmentCode': departmentCode, 'name': name};
}
