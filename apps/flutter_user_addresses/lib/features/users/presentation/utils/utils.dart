import 'package:flutter_user_addresses/features/users/user_models.dart';

bool hasCoords(AddressDto a) => a.latitude != null && a.longitude != null;
