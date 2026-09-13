// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Flowerist';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get email => 'Tu correo electrónico';

  @override
  String get password => 'Tu contraseña';

  @override
  String get name => 'Tu nombre';

  @override
  String get customer => 'Cliente';

  @override
  String get seller => 'Tienda';

  @override
  String get home => 'Inicio';

  @override
  String get search => 'Buscar';

  @override
  String get cart => 'Carrito';

  @override
  String get profile => 'Perfil';

  @override
  String get addToCart => 'Añadir al Carrito';

  @override
  String get checkout => 'Pagar';

  @override
  String get confirmOrder => 'Confirmar Pedido';

  @override
  String get orderSuccess => '¡Tu pedido ha sido realizado! 🌸';

  @override
  String get emptyCart => 'Tu carrito está vacío';

  @override
  String get total => 'Total';

  @override
  String get deliveryAddress => 'Dirección de Entrega';

  @override
  String get cardNumber => 'Número de Tarjeta';

  @override
  String get myOrders => 'Mis Pedidos';

  @override
  String get favorites => 'Favoritos';

  @override
  String get myAddresses => 'Mis Direcciones';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma de la App';

  @override
  String get security => 'Seguridad';

  @override
  String get registerSuccess => '¡Registro exitoso! Bienvenido. 🌸';

  @override
  String get loginFailed => 'Inicio de sesión fallido. Verifica tus datos.';

  @override
  String get emailInUse =>
      'Este correo ya está registrado. Intenta iniciar sesión.';

  @override
  String get enterEmail => 'Ingresa tu correo electrónico';

  @override
  String get validEmail => 'Ingresa un correo válido';

  @override
  String get enterPassword => 'Ingresa tu contraseña';

  @override
  String get passwordMin => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get enterName => 'Ingresa tu nombre';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get haveAccount => '¿Ya tienes cuenta?';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get joinUs => 'Únete';

  @override
  String get storeLogin => 'Acceso Tienda';

  @override
  String get differentStore => 'Tienda Diferente';

  @override
  String get differentStoreMsg => 'Tu carrito tiene productos de otra tienda.';

  @override
  String get clearCart => 'Vaciar Carrito';

  @override
  String get cancel => 'Cancelar';

  @override
  String addedToCart(Object name) {
    return '¡$name añadido al carrito!';
  }

  @override
  String get price => 'Precio';

  @override
  String get category => 'Categoría';

  @override
  String get description => 'Descripción';

  @override
  String get flowerName => 'Nombre de la Flor';

  @override
  String get addFlower => 'Añadir Nueva Flor';

  @override
  String get addToStore => 'Añadir a la Tienda';

  @override
  String get noFlowers => 'Aún no hay flores en esta tienda.';
}
