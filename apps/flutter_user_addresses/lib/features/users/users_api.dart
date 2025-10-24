import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import 'user_models.dart';

class UserApi {
  final http.Client _client;
  UserApi({http.Client? client}) : _client = client ?? http.Client();

  // GET /users
  Future<List<UserDto>> list() async {
    final url = Uri.parse('$kApiBase/users');
    final res = await _client.get(url, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('GET /users failed: ${res.statusCode} — ${res.body}');
    }
    final data = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    return data.map((e) => UserDto.fromJson(e)).toList();
    // NOTE: If your API returns ISO date ("YYYY-MM-DD"), our model parses it.
  }

  // GET /users/{id}
  Future<UserDto> getById(int id) async {
    final url = Uri.parse('$kApiBase/users/$id');
    final res = await _client.get(url, headers: {'Accept': 'application/json'});
    if (res.statusCode == 404) throw Exception('User $id not found');
    if (res.statusCode != 200) {
      throw Exception('GET /users/$id failed: ${res.statusCode} — ${res.body}');
    }
    return UserDto.fromJson(jsonDecode(res.body));
  }

  // POST /users
  Future<UserDto> create(UserDto dto) async {
    final url = Uri.parse('$kApiBase/users');
    final res = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()
        // backend expects "YYYY-MM-DD"; we already send split('T').first in toJson()
      ),
    );
    if (res.statusCode != 201) {
      throw Exception('POST /users failed: ${res.statusCode} — ${res.body}');
    }
    return UserDto.fromJson(jsonDecode(res.body));
  }

  // PUT /users/{id}
  Future<UserDto> update(UserDto dto) async {
    if (dto.id == null) throw ArgumentError('update requires dto.id');
    final url = Uri.parse('$kApiBase/users/${dto.id}');
    final res = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception('PUT /users/${dto.id} failed: ${res.statusCode} — ${res.body}');
    }
    return UserDto.fromJson(jsonDecode(res.body));
  }

  // DELETE /users/{id}
  Future<void> delete(int id) async {
    final url = Uri.parse('$kApiBase/users/$id');
    final res = await _client.delete(url);
    if (res.statusCode == 404) {
      // idempotent UX — treat as success if already gone
      return;
    }
    if (res.statusCode != 204) {
      throw Exception('DELETE /users/$id failed: ${res.statusCode} — ${res.body}');
    }
  }

  // GET /geocode?q=...
  Future<({double lat, double lon})?> geocode(String query) async {
    final url = Uri.parse('$kApiBase/geocode?q=${Uri.encodeQueryComponent(query)}');
    final res = await _client.get(url, headers: {'Accept': 'application/json'});
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw Exception('GET /geocode failed: ${res.statusCode} — ${res.body}');
    }
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    return (lat: (j['lat'] as num).toDouble(), lon: (j['lon'] as num).toDouble());
  }
}
