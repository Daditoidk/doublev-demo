import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import 'catalog_models.dart';

class CatalogApi {
  final http.Client _client;

  CatalogApi({http.Client? client}) : _client = client ?? http.Client();

  /// GET /catalog/countries
  Future<List<Country>> getCountries() async {
    final url = Uri.parse('$kApiBase/catalog/countries');
    final res = await _client.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to load countries');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => Country.fromJson(e)).toList();
  }

  /// GET /catalog/departments?countryCode=CO
  Future<List<Department>> getDepartments(String countryCode) async {
    final url =
        Uri.parse('$kApiBase/catalog/departments?countryCode=$countryCode');
    final res = await _client.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to load departments');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => Department.fromJson(e)).toList();
  }

  /// GET /catalog/municipalities?departmentCode=CUN
  Future<List<Municipality>> getMunicipalities(String departmentCode) async {
    final url =
        Uri.parse('$kApiBase/catalog/municipalities?departmentCode=$departmentCode');
    final res = await _client.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to load municipalities');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => Municipality.fromJson(e)).toList();
  }
}
