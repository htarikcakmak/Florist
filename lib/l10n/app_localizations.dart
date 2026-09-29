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
  /// **'Keşfet'**
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
  /// **'Sipariş Tamamla'**
  String get checkout;

  /// No description provided for @confirmOrder.
  ///
  /// In tr, this message translates to:
  /// **'Siparişi Onayla'**
  String get confirmOrder;

  /// No description provided for @orderSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Siparişiniz alındı! 🌸'**
  String get orderSuccess;

  /// No description provided for @emptyCart.
  ///
  /// In tr, this message translates to:
  /// **'Sepetin boş'**
  String get emptyCart;

  /// No description provided for @emptyCartSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Güzel çiçekler keşfetmeye başla! 🌸'**
  String get emptyCartSubtitle;

  /// No description provided for @startShopping.
  ///
  /// In tr, this message translates to:
  /// **'Alışverişe Başla'**
  String get startShopping;

  /// No description provided for @total.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In tr, this message translates to:
  /// **'Ara Toplam'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In tr, this message translates to:
  /// **'Kargo'**
  String get shipping;

  /// No description provided for @freeShipping.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz'**
  String get freeShipping;

  /// No description provided for @completeOrder.
  ///
  /// In tr, this message translates to:
  /// **'Siparişi Tamamla'**
  String get completeOrder;

  /// No description provided for @deliveryAddress.
  ///
  /// In tr, this message translates to:
  /// **'Teslimat Adresi'**
  String get deliveryAddress;

  /// No description provided for @paymentInfo.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme Bilgileri'**
  String get paymentInfo;

  /// No description provided for @cardNumber.
  ///
  /// In tr, this message translates to:
  /// **'Kart Numarası'**
  String get cardNumber;

  /// No description provided for @creditCard.
  ///
  /// In tr, this message translates to:
  /// **'Kredi Kartı'**
  String get creditCard;

  /// No description provided for @cashOnDelivery.
  ///
  /// In tr, this message translates to:
  /// **'Kapıda Ödeme'**
  String get cashOnDelivery;

  /// No description provided for @orderSummary.
  ///
  /// In tr, this message translates to:
  /// **'Sipariş Özeti'**
  String get orderSummary;

  /// No description provided for @address.
  ///
  /// In tr, this message translates to:
  /// **'Adres'**
  String get address;

  /// No description provided for @payment.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme'**
  String get payment;

  /// No description provided for @confirm.
  ///
  /// In tr, this message translates to:
  /// **'Onay'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @continueText.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueText;

  /// No description provided for @pay.
  ///
  /// In tr, this message translates to:
  /// **'Öde'**
  String get pay;

  /// No description provided for @orderNote.
  ///
  /// In tr, this message translates to:
  /// **'Sipariş Notu'**
  String get orderNote;

  /// No description provided for @addNewAddress.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Adres Ekle'**
  String get addNewAddress;

  /// No description provided for @orderReceived.
  ///
  /// In tr, this message translates to:
  /// **'Siparişiniz Alındı! 🌸'**
  String get orderReceived;

  /// No description provided for @flowersOnTheWay.
  ///
  /// In tr, this message translates to:
  /// **'Çiçekleriniz yola çıkacak'**
  String get flowersOnTheWay;

  /// No description provided for @goHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfaya Dön'**
  String get goHome;

  /// No description provided for @clearCartBtn.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clearCartBtn;

  /// No description provided for @cartCleared.
  ///
  /// In tr, this message translates to:
  /// **'Sepet temizlendi'**
  String get cartCleared;

  /// No description provided for @removedFromCart.
  ///
  /// In tr, this message translates to:
  /// **'sepetten çıkarıldı'**
  String get removedFromCart;

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
  /// **'Dil'**
  String get language;

  /// No description provided for @security.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get security;

  /// No description provided for @help.
  ///
  /// In tr, this message translates to:
  /// **'Yardım'**
  String get help;

  /// No description provided for @theme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @noOrders.
  ///
  /// In tr, this message translates to:
  /// **'Henüz siparişin yok'**
  String get noOrders;

  /// No description provided for @noOrdersSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İlk siparişini vermek için keşfet! 🌸'**
  String get noOrdersSubtitle;

  /// No description provided for @noFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Henüz favori yok'**
  String get noFavorites;

  /// No description provided for @noFavoritesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Beğendiğin çiçeklere ❤️ bas!'**
  String get noFavoritesSubtitle;

  /// No description provided for @writeReview.
  ///
  /// In tr, this message translates to:
  /// **'Yorum Yap'**
  String get writeReview;

  /// No description provided for @nearbyStores.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki Mağazalar'**
  String get nearbyStores;

  /// No description provided for @allStores.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get allStores;

  /// No description provided for @categories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get categories;

  /// No description provided for @noStores.
  ///
  /// In tr, this message translates to:
  /// **'Henüz aktif mağaza yok'**
  String get noStores;

  /// No description provided for @roses.
  ///
  /// In tr, this message translates to:
  /// **'Güller'**
  String get roses;

  /// No description provided for @orchid.
  ///
  /// In tr, this message translates to:
  /// **'Orkide'**
  String get orchid;

  /// No description provided for @daisy.
  ///
  /// In tr, this message translates to:
  /// **'Papatya'**
  String get daisy;

  /// No description provided for @bouquet.
  ///
  /// In tr, this message translates to:
  /// **'Buket'**
  String get bouquet;

  /// No description provided for @potted.
  ///
  /// In tr, this message translates to:
  /// **'Saksı'**
  String get potted;

  /// No description provided for @bridal.
  ///
  /// In tr, this message translates to:
  /// **'Gelin'**
  String get bridal;

  /// No description provided for @birthday.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Günü'**
  String get birthday;

  /// No description provided for @forLove.
  ///
  /// In tr, this message translates to:
  /// **'Sevgiliye'**
  String get forLove;

  /// No description provided for @results.
  ///
  /// In tr, this message translates to:
  /// **'Sonuçlar'**
  String get results;

  /// No description provided for @allVendors.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Mağazalar'**
  String get allVendors;

  /// No description provided for @noResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noResults;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Çiçek, mağaza veya kategori ara...'**
  String get searchHint;

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
  /// **'Bu e-posta zaten kayıtlı.'**
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

  /// No description provided for @onboarding1Title.
  ///
  /// In tr, this message translates to:
  /// **'Güzel Çiçekler Keşfet'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yüzlerce çiçek ve buket arasından seçim yapın.'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Teslimat'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Siparişiniz en kısa sürede kapınıza gelsin.'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding3Title.
  ///
  /// In tr, this message translates to:
  /// **'Satıcı Ol'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kendi mağazanı aç, çiçeklerini sat.'**
  String get onboarding3Subtitle;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get skip;

  /// No description provided for @letsStart.
  ///
  /// In tr, this message translates to:
  /// **'Başlayalım!'**
  String get letsStart;

  /// No description provided for @pending.
  ///
  /// In tr, this message translates to:
  /// **'Beklemede'**
  String get pending;

  /// No description provided for @preparing.
  ///
  /// In tr, this message translates to:
  /// **'Hazırlanıyor'**
  String get preparing;

  /// No description provided for @shipped.
  ///
  /// In tr, this message translates to:
  /// **'Kargoda'**
  String get shipped;

  /// No description provided for @delivered.
  ///
  /// In tr, this message translates to:
  /// **'Teslim Edildi'**
  String get delivered;
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
