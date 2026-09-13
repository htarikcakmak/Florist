// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flowerist';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Sign In';

  @override
  String get register => 'Sign Up';

  @override
  String get logout => 'Sign Out';

  @override
  String get email => 'Your email address';

  @override
  String get password => 'Your password';

  @override
  String get name => 'Your name';

  @override
  String get customer => 'Customer';

  @override
  String get seller => 'Store';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get checkout => 'Checkout';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get orderSuccess => 'Your order has been placed! 🌸';

  @override
  String get emptyCart => 'Your cart is empty';

  @override
  String get total => 'Total';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get myOrders => 'My Orders';

  @override
  String get favorites => 'Favorites';

  @override
  String get myAddresses => 'My Addresses';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'App Language';

  @override
  String get security => 'Security';

  @override
  String get registerSuccess => 'Registration successful! Welcome. 🌸';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get emailInUse => 'This email is already registered. Try signing in.';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get validEmail => 'Enter a valid email';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get passwordMin => 'Password must be at least 6 characters';

  @override
  String get enterName => 'Please enter your name';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinUs => 'Join Us';

  @override
  String get storeLogin => 'Store Login';

  @override
  String get differentStore => 'Different Store';

  @override
  String get differentStoreMsg => 'Your cart has items from another store.';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get cancel => 'Cancel';

  @override
  String addedToCart(Object name) {
    return '$name added to cart!';
  }

  @override
  String get price => 'Price';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get flowerName => 'Flower Name';

  @override
  String get addFlower => 'Add New Flower';

  @override
  String get addToStore => 'Add to Store';

  @override
  String get noFlowers => 'No flowers in this store yet.';
}
