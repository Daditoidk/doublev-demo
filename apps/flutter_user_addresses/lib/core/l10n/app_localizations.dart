import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get appTitle;

  /// No description provided for @addProperty.
  ///
  /// In en, this message translates to:
  /// **'Add Property'**
  String get addProperty;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(Object message);

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @noUserSelected.
  ///
  /// In en, this message translates to:
  /// **'No user selected.'**
  String get noUserSelected;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addAddress;

  /// No description provided for @noAddressesYet.
  ///
  /// In en, this message translates to:
  /// **'There are no addresses yet.'**
  String get noAddressesYet;

  /// No description provided for @addressWithoutLine1.
  ///
  /// In en, this message translates to:
  /// **'(No line 1)'**
  String get addressWithoutLine1;

  /// No description provided for @deleteAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete address'**
  String get deleteAddressTitle;

  /// No description provided for @confirmDeleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{address}\"?'**
  String confirmDeleteAddress(Object address);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @editAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get editAddressTitle;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get saveAddress;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {message}'**
  String errorSaving(Object message);

  /// No description provided for @errorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Error deleting: {message}'**
  String errorDeleting(Object message);

  /// No description provided for @addressDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (e.g. Funza, Cundinamarca)'**
  String get addressDialogLabel;

  /// No description provided for @addressExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Funza, Cundinamarca'**
  String get addressExample;

  /// No description provided for @defaultAddressExample.
  ///
  /// In en, this message translates to:
  /// **'Funza, Cundinamarca'**
  String get defaultAddressExample;

  /// No description provided for @geocode.
  ///
  /// In en, this message translates to:
  /// **'Geocode'**
  String get geocode;

  /// No description provided for @geocodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not geocode that address'**
  String get geocodeFailed;

  /// No description provided for @propertyAdded.
  ///
  /// In en, this message translates to:
  /// **'Property added'**
  String get propertyAdded;

  /// No description provided for @goToProfile.
  ///
  /// In en, this message translates to:
  /// **'Go to profile'**
  String get goToProfile;

  /// No description provided for @noUserSelectedHelp.
  ///
  /// In en, this message translates to:
  /// **'No user selected.\nCreate one in Onboarding or choose in Profile.'**
  String get noUserSelectedHelp;

  /// No description provided for @mustAddAtLeastOneAddress.
  ///
  /// In en, this message translates to:
  /// **'You must add at least one address/property.'**
  String get mustAddAtLeastOneAddress;

  /// No description provided for @addressHasIncompleteFields.
  ///
  /// In en, this message translates to:
  /// **'Address {index} has incomplete fields.'**
  String addressHasIncompleteFields(Object index);

  /// No description provided for @welcomeUserSuccess.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}! User created successfully'**
  String welcomeUserSuccess(Object name);

  /// No description provided for @createProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get createProfileTitle;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @yourProperties.
  ///
  /// In en, this message translates to:
  /// **'Your properties'**
  String get yourProperties;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noPropertiesYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added properties'**
  String get noPropertiesYet;

  /// No description provided for @addPropertyToContinue.
  ///
  /// In en, this message translates to:
  /// **'Add at least one property to continue'**
  String get addPropertyToContinue;

  /// No description provided for @createUserAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Create user and continue'**
  String get createUserAndContinue;

  /// No description provided for @complementOptional.
  ///
  /// In en, this message translates to:
  /// **'Complement (optional)'**
  String get complementOptional;

  /// No description provided for @addressLine1Hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Street 123 #45-67'**
  String get addressLine1Hint;

  /// No description provided for @addressLine2Hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Apt 301, Tower B'**
  String get addressLine2Hint;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @municipality.
  ///
  /// In en, this message translates to:
  /// **'Municipality'**
  String get municipality;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @propertyNumber.
  ///
  /// In en, this message translates to:
  /// **'Property {index}'**
  String propertyNumber(Object index);

  /// No description provided for @errorLoadingCountries.
  ///
  /// In en, this message translates to:
  /// **'Error loading countries: {message}'**
  String errorLoadingCountries(Object message);

  /// No description provided for @errorLoadingDepartments.
  ///
  /// In en, this message translates to:
  /// **'Error loading departments: {message}'**
  String errorLoadingDepartments(Object message);

  /// No description provided for @errorLoadingMunicipalities.
  ///
  /// In en, this message translates to:
  /// **'Error loading municipalities: {message}'**
  String errorLoadingMunicipalities(Object message);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
