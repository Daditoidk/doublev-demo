import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'catalog_api.dart';
import 'catalog_models.dart';

final catalogApiProvider = Provider((ref) => CatalogApi());

final countriesProvider = FutureProvider<List<Country>>((ref) {
  final api = ref.read(catalogApiProvider);
  return api.getCountries();
});

final departmentsProvider = FutureProvider.family<List<Department>, String>((
  ref,
  countryCode,
) {
  final api = ref.read(catalogApiProvider);
  return api.getDepartments(countryCode);
});

final municipalitiesProvider =
    FutureProvider.family<List<Municipality>, String>((ref, departmentCode) {
      final api = ref.read(catalogApiProvider);
      return api.getMunicipalities(departmentCode);
    });
