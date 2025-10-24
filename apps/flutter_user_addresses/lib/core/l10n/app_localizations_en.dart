// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Properties';

  @override
  String get addProperty => 'Add Property';

  @override
  String get profile => 'Profile';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get address => 'Address';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get noUserSelected => 'No user selected.';

  @override
  String get addresses => 'Addresses';

  @override
  String get addAddress => 'Add address';

  @override
  String get noAddressesYet => 'There are no addresses yet.';

  @override
  String get addressWithoutLine1 => '(No line 1)';

  @override
  String get deleteAddressTitle => 'Delete address';

  @override
  String confirmDeleteAddress(Object address) {
    return 'Delete \"$address\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get editAddressTitle => 'Edit address';

  @override
  String get saveAddress => 'Save address';

  @override
  String errorSaving(Object message) {
    return 'Error saving: $message';
  }

  @override
  String errorDeleting(Object message) {
    return 'Error deleting: $message';
  }

  @override
  String get addressDialogLabel => 'Address (e.g. Funza, Cundinamarca)';

  @override
  String get addressExample => 'e.g. Funza, Cundinamarca';

  @override
  String get defaultAddressExample => 'Funza, Cundinamarca';

  @override
  String get geocode => 'Geocode';

  @override
  String get geocodeFailed => 'Could not geocode that address';

  @override
  String get propertyAdded => 'Property added';

  @override
  String get goToProfile => 'Go to profile';

  @override
  String get noUserSelectedHelp =>
      'No user selected.\nCreate one in Onboarding or choose in Profile.';

  @override
  String get mustAddAtLeastOneAddress =>
      'You must add at least one address/property.';

  @override
  String addressHasIncompleteFields(Object index) {
    return 'Address $index has incomplete fields.';
  }

  @override
  String welcomeUserSuccess(Object name) {
    return 'Welcome $name! User created successfully';
  }

  @override
  String get createProfileTitle => 'Create your profile';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get selectDate => 'Select date';

  @override
  String get yourProperties => 'Your properties';

  @override
  String get add => 'Add';

  @override
  String get noPropertiesYet => 'You haven\'t added properties';

  @override
  String get addPropertyToContinue => 'Add at least one property to continue';

  @override
  String get createUserAndContinue => 'Create user and continue';

  @override
  String get complementOptional => 'Complement (optional)';

  @override
  String get addressLine1Hint => 'e.g. Street 123 #45-67';

  @override
  String get addressLine2Hint => 'e.g. Apt 301, Tower B';

  @override
  String get country => 'Country';

  @override
  String get department => 'Department';

  @override
  String get municipality => 'Municipality';

  @override
  String get requiredField => 'Required field';

  @override
  String propertyNumber(Object index) {
    return 'Property $index';
  }

  @override
  String errorLoadingCountries(Object message) {
    return 'Error loading countries: $message';
  }

  @override
  String errorLoadingDepartments(Object message) {
    return 'Error loading departments: $message';
  }

  @override
  String errorLoadingMunicipalities(Object message) {
    return 'Error loading municipalities: $message';
  }
}
