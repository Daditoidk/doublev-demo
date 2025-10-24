import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_user_addresses/features/catalog/catalog_api.dart';

void main() {
  final api = CatalogApi();

  group('CatalogApi Integration', () {
    test('Get countries returns list with Colombia', () async {
      final countries = await api.getCountries();

      expect(countries, isNotEmpty, reason: 'Countries list should not be empty');
      expect(countries.any((c) => c.code == 'CO'), true,
          reason: 'Colombia should exist in the countries list');
    });

    test('Get departments for CO returns list', () async {
      final deps = await api.getDepartments('CO');

      expect(deps, isNotEmpty, reason: 'Departments list should not be empty');
      expect(deps.any((d) => d.code == 'CUN'), true,
          reason: 'Cundinamarca should exist for CO');
    });

    test('Get municipalities for CUN returns list', () async {
      final munis = await api.getMunicipalities('CUN');

      expect(munis, isNotEmpty, reason: 'Municipalities list should not be empty');
      expect(munis.any((m) => m.code == 'BOG'), true,
          reason: 'Bogotá should exist for Cundinamarca');
    });

    test('Invalid codes return empty lists instead of errors', () async {
      final deps = await api.getDepartments('XXX');
      final munis = await api.getMunicipalities('ZZZ');

      expect(deps, isEmpty, reason: 'Invalid countryCode should return empty list');
      expect(munis, isEmpty,
          reason: 'Invalid departmentCode should return empty list, not throw');
    });
  });
}
