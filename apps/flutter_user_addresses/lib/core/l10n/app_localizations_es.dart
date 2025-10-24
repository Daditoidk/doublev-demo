// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mis Propiedades';

  @override
  String get addProperty => 'Agregar Propiedad';

  @override
  String get profile => 'Perfil';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get birthDate => 'Fecha de Nacimiento';

  @override
  String get address => 'Dirección';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get profileSaved => 'Perfil guardado';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get noUserSelected => 'No hay usuario seleccionado.';

  @override
  String get addresses => 'Direcciones';

  @override
  String get addAddress => 'Agregar dirección';

  @override
  String get noAddressesYet => 'Aún no hay direcciones.';

  @override
  String get addressWithoutLine1 => '(Sin línea 1)';

  @override
  String get deleteAddressTitle => 'Eliminar dirección';

  @override
  String confirmDeleteAddress(Object address) {
    return '¿Eliminar \"$address\"?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get saveProfile => 'Guardar perfil';

  @override
  String get editAddressTitle => 'Editar dirección';

  @override
  String get saveAddress => 'Guardar dirección';

  @override
  String errorSaving(Object message) {
    return 'Error al guardar: $message';
  }

  @override
  String errorDeleting(Object message) {
    return 'Error al eliminar: $message';
  }

  @override
  String get addressDialogLabel => 'Dirección (ej. Funza, Cundinamarca)';

  @override
  String get addressExample => 'ej. Funza, Cundinamarca';

  @override
  String get defaultAddressExample => 'Funza, Cundinamarca';

  @override
  String get geocode => 'Geocodificar';

  @override
  String get geocodeFailed => 'No se pudo geocodificar esa dirección';

  @override
  String get propertyAdded => 'Propiedad agregada';

  @override
  String get goToProfile => 'Ir al perfil';

  @override
  String get noUserSelectedHelp =>
      'No hay usuario seleccionado.\nCrea uno en Onboarding o selecciónalo en Perfil.';

  @override
  String get mustAddAtLeastOneAddress =>
      'Debes agregar al menos una dirección/propiedad.';

  @override
  String addressHasIncompleteFields(Object index) {
    return 'La dirección $index tiene campos incompletos.';
  }

  @override
  String welcomeUserSuccess(Object name) {
    return '¡Bienvenido $name! Usuario creado exitosamente';
  }

  @override
  String get createProfileTitle => 'Crear tu perfil';

  @override
  String get personalInformation => 'Información personal';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get yourProperties => 'Tus propiedades';

  @override
  String get add => 'Agregar';

  @override
  String get noPropertiesYet => 'No has agregado propiedades';

  @override
  String get addPropertyToContinue =>
      'Agrega al menos una propiedad para continuar';

  @override
  String get createUserAndContinue => 'Crear usuario y continuar';

  @override
  String get complementOptional => 'Complemento (opcional)';

  @override
  String get addressLine1Hint => 'ej. Calle 123 #45-67';

  @override
  String get addressLine2Hint => 'ej. Apto 301, Torre B';

  @override
  String get country => 'País';

  @override
  String get department => 'Departamento';

  @override
  String get municipality => 'Municipio';

  @override
  String get requiredField => 'Campo requerido';

  @override
  String propertyNumber(Object index) {
    return 'Propiedad $index';
  }

  @override
  String errorLoadingCountries(Object message) {
    return 'Error cargando países: $message';
  }

  @override
  String errorLoadingDepartments(Object message) {
    return 'Error cargando departamentos: $message';
  }

  @override
  String errorLoadingMunicipalities(Object message) {
    return 'Error cargando municipios: $message';
  }
}
