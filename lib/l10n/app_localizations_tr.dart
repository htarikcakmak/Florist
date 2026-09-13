// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Flowerist';

  @override
  String get welcome => 'Hoş Geldiniz';

  @override
  String get login => 'Giriş Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get email => 'E-posta adresiniz';

  @override
  String get password => 'Şifreniz';

  @override
  String get name => 'Adınız';

  @override
  String get customer => 'Müşteri';

  @override
  String get seller => 'Mağaza';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get search => 'Arama';

  @override
  String get cart => 'Sepet';

  @override
  String get profile => 'Profil';

  @override
  String get addToCart => 'Sepete Ekle';

  @override
  String get checkout => 'Ödeme';

  @override
  String get confirmOrder => 'Siparişi Onayla';

  @override
  String get orderSuccess => 'Siparişiniz başarıyla alındı! 🌸';

  @override
  String get emptyCart => 'Sepetiniz boş';

  @override
  String get total => 'Toplam';

  @override
  String get deliveryAddress => 'Teslimat Adresi';

  @override
  String get cardNumber => 'Kart Numarası';

  @override
  String get myOrders => 'Siparişlerim';

  @override
  String get favorites => 'Favorilerim';

  @override
  String get myAddresses => 'Adreslerim';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Uygulama Dili';

  @override
  String get security => 'Güvenlik';

  @override
  String get registerSuccess => 'Kayıt başarılı! Hoş geldiniz. 🌸';

  @override
  String get loginFailed =>
      'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.';

  @override
  String get emailInUse => 'Bu e-posta zaten kayıtlı. Giriş yapmayı deneyin.';

  @override
  String get enterEmail => 'Lütfen e-posta adresinizi girin';

  @override
  String get validEmail => 'Geçerli bir e-posta girin';

  @override
  String get enterPassword => 'Lütfen şifrenizi girin';

  @override
  String get passwordMin => 'Şifre en az 6 karakter olmalı';

  @override
  String get enterName => 'Lütfen bir ad girin';

  @override
  String get noAccount => 'Hesabın yok mu?';

  @override
  String get haveAccount => 'Zaten hesabın var mı?';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get joinUs => 'Aramıza katılın';

  @override
  String get storeLogin => 'Mağaza Girişi';

  @override
  String get differentStore => 'Farklı Mağaza';

  @override
  String get differentStoreMsg =>
      'Sepetinizde başka bir mağazaya ait ürünler var.';

  @override
  String get clearCart => 'Sepeti Temizle';

  @override
  String get cancel => 'İptal';

  @override
  String addedToCart(Object name) {
    return '$name sepete eklendi!';
  }

  @override
  String get price => 'Fiyat';

  @override
  String get category => 'Kategori';

  @override
  String get description => 'Açıklama';

  @override
  String get flowerName => 'Çiçek Adı';

  @override
  String get addFlower => 'Yeni Çiçek Ekle';

  @override
  String get addToStore => 'Dükkana Ekle';

  @override
  String get noFlowers => 'Bu mağazada henüz çiçek bulunmuyor.';
}
