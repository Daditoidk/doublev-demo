import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_user_addresses/features/users/user_models.dart';
import 'package:flutter_user_addresses/features/users/users_api.dart';

void main() {
  late UserApi api;

  setUp(() {
    api = UserApi(); // uses kApiBase inside
  });

  // Helper to create a user dto quickly
  UserDto makeUser({String fn = 'Alice', String ln = 'Tester'}) => UserDto(
        firstName: fn,
        lastName: ln,
        birthDate: DateTime(2000, 1, 1),
        addresses: [
          AddressDto(
            line1: 'Cra 1 #2-3',
            countryCode: 'CO',
            departmentCode: 'CUN',
            municipalityCode: 'BOG',
            latitude: 4.711,
            longitude: -74.072,
          )
        ],
      );

  group('UserApi Integration', () {
    test('list() - happy path returns a list (may be empty)', () async {
      final users = await api.list();
      expect(users, isA<List<UserDto>>());
      // Happy path: if backend already has users, we at least verify it doesn’t throw.
      // (More asserts happen after we create a user below.)
    });

    test('create() - happy path returns created user with id', () async {
      final created = await api.create(makeUser(fn: 'Cam', ln: 'Bar'));
      expect(created.id, isNotNull);
      expect(created.firstName, 'Cam');
      expect(created.lastName, 'Bar');
    });

    test('getById() - happy path returns the created user', () async {
      final created = await api.create(makeUser(fn: 'Bob', ln: 'Marley'));
      final fetched = await api.getById(created.id!);

      expect(fetched.id, created.id);
      expect(fetched.firstName, 'Bob');
      expect(fetched.lastName, 'Marley');
      expect(fetched.addresses, isNotEmpty);
    });

    test('update() - happy path updates lastName', () async {
      final created = await api.create(makeUser(fn: 'Eve', ln: 'Old'));
      final updated = await api.update(
        UserDto(
          id: created.id,
          firstName: created.firstName,
          lastName: 'New',
          birthDate: created.birthDate,
          addresses: created.addresses,
        ),
      );

      expect(updated.lastName, 'New');

      final roundTrip = await api.getById(created.id!);
      expect(roundTrip.lastName, 'New');
    });

    test('delete() - happy path deletes and subsequent getById throws', () async {
      final created = await api.create(makeUser(fn: 'Zed', ln: 'ToDelete'));
      await api.delete(created.id!);

      // After delete, GET should 404 -> our client throws
      expect(() => api.getById(created.id!), throwsA(isA<Exception>()));
    });

    test('geocode() - happy path returns coords for a valid query', () async {
      final res = await api.geocode('Funza, Cundinamarca, Colombia');
      expect(res, isNotNull);
      expect(res!.lat, isA<double>());
      expect(res.lon, isA<double>());
    });

    // -------- Edge cases 

    test('list() - edge: still returns a list even if empty', () async {
      // We can’t force empty DB from here, but we can assert the contract:
      final users = await api.list();
      expect(users, isA<List<UserDto>>()); // Not throwing & always a list
    });

    test('getById() - edge: invalid id throws', () async {
      expect(() => api.getById(999999), throwsA(isA<Exception>()));
    });

    test('create() - edge: minimal valid payload still succeeds', () async {
      // Your backend allows null line2/lat/lon; minimal but valid
      final dto = UserDto(
        firstName: 'Mini',
        lastName: 'Mal',
        birthDate: DateTime(1999, 9, 9),
        addresses: [
          AddressDto(
            line1: 'CL 10 # 10-10',
            countryCode: 'CO',
            departmentCode: 'CUN',
            municipalityCode: 'BOG',
          )
        ],
      );
      final created = await api.create(dto);
      expect(created.id, isNotNull);
    });

    test('update() - edge: calling without id throws ArgumentError', () async {
      final dto = makeUser(fn: 'No', ln: 'Id'); // no id
      expect(() => api.update(dto), throwsA(isA<ArgumentError>()));
    });

    test('delete() - edge: deleting non-existing id is idempotent (no throw)', () async {
      await api.delete(42424242); // our client treats 404 as success
    });

    test('geocode() - edge: nonsense query returns null', () async {
      final res = await api.geocode('zzzz-not-a-place-!!!');
      expect(res, isNull);
    });
  });
}
