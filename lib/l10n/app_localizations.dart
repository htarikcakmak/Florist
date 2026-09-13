import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Flowerist'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @register.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresiniz'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifreniz'**
  String get password;

  /// No description provided for @name.
  ///
  /// In tr, this message translates to:
  /// **'Adınız'**
  String get name;

  /// No description provided for @customer.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri'**
  String get customer;

  /// No description provided for @seller.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza'**
  String get seller;

  /// No description provided for @home.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get home;

  /// No description provided for @search.
  ///
  /// In tr, this message translates to:
  /// **'Arama'**
  String get search;

  /// No description provided for @cart.
  ///
  /// In tr, this message translates to:
  /// **'Sepet'**
  String get cart;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @addToCart.
  ///
  /// In tr, this message translates to:
  /// **'Sepete Ekle'**
  String get addToCart;

  /// No description provided for @checkout.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme'**
  String get checkout;

  /// No description provided for @confirmOrder.
  ///
  /// In tr, this message translates to:
  /// **'Siparişi Onayla'**
  String get confirmOrder;

  /// No description provided for @orderSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Siparişiniz başarıyla alındı! 🌸'**
  String get orderSuccess;

  /// No description provided for @emptyCart.
  ///
  /// In tr, this message translates to:
  /// **'Sepetiniz boş'**
  String get emptyCart;

  /// No description provided for @total.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get total;

  /// No description provided for @deliveryAddress.
  ///
  /// In tr, this message translates to:
  /// **'Teslimat Adresi'**
  String get deliveryAddress;

  /// No description provided for @cardNumber.
  ///
  /// In tr, this message translates to:
  /// **'Kart Numarası'**
  String get cardNumber;

  /// No description provided for @myOrders.
  ///
  /// In tr, this message translates to:
  /// **'Siparişlerim'**
  String get myOrders;

  /// No description provided for @favorites.
  ///
  /// In tr, this message translates to:
  /// **'Favorilerim'**
  String get favorites;

  /// No description provided for @myAddresses.
  ///
  /// In tr, this message translates to:
  /// **'Adreslerim'**
  String get myAddresses;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Dili'**
  String get language;

  /// No description provided for @security.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get security;

  /// No description provided for @registerSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarılı! Hoş geldiniz. 🌸'**
  String get registerSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.'**
  String get loginFailed;

  /// No description provided for @emailInUse.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta zaten kayıtlı. Giriş yapmayı deneyin.'**
  String get emailInUse;

  /// No description provided for @enterEmail.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen e-posta adresinizi girin'**
  String get enterEmail;

  /// No description provided for @validEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta girin'**
  String get validEmail;

  /// No description provided for @enterPassword.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen şifrenizi girin'**
  String get enterPassword;

  /// No description provided for @passwordMin.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalı'**
  String get passwordMin;

  /// No description provided for @enterName.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir ad girin'**
  String get enterName;

  /// No description provided for @noAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı?'**
  String get haveAccount;

  /// No description provided for @createAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get createAccount;

  /// No description provided for @joinUs.
  ///
  /// In tr, this message translates to:
  /// **'Aramıza katılın'**
  String get joinUs;

  /// No description provided for @storeLogin.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza Girişi'**
  String get storeLogin;

  /// No description provided for @differentStore.
  ///
  /// In tr, this message translates to:
  /// **'Farklı Mağaza'**
  String get differentStore;

  /// No description provided for @differentStoreMsg.
  ///
  /// In tr, this message translates to:
  /// **'Sepetinizde başka bir mağazaya ait ürünler var.'**
  String get differentStoreMsg;

  /// No description provided for @clearCart.
  ///
  /// In tr, this message translates to:
  /// **'Sepeti Temizle'**
  String get clearCart;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @addedToCart.
  ///
  /// In tr, this message translates to:
  /// **'{name} sepete eklendi!'**
  String addedToCart(Object name);

  /// No description provided for @price.
  ///
  /// In tr, this message translates to:
  /// **'Fiyat'**
  String get price;

  /// No description provided for @category.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @description.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get description;

  /// No description provided for @flowerName.
  ///
  /// In tr, this message translates to:
  /// **'Çiçek Adı'**
  String get flowerName;

  /// No description provided for @addFlower.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Çiçek Ekle'**
  String get addFlower;

  /// No description provided for @addToStore.
  ///
  /// In tr, this message translates to:
  /// **'Dükkana Ekle'**
  String get addToStore;

  /// No description provided for @noFlowers.
  ///
  /// In tr, this message translates to:
  /// **'Bu mağazada henüz çiçek bulunmuyor.'**
  String get noFlowers;
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
      <String>['en', 'es', 'tr'].contains(locale.languageCode);

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
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
