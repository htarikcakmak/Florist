# 🌸 Flowerist App — Flutter Frontend

**Flowerist**, çiçek satıcılarını ve müşterileri buluşturan modern bir e-ticaret mobil uygulamasıdır. Flutter ile geliştirilmiştir ve Spring Boot arka uçla REST API aracılığıyla haberleşir.

## 📱 Ekran Görüntüleri & Özellikler

| Özellik | Açıklama |
|---|---|
| **Glassmorphism Tasarım** | Buzlu cam efektli kartlar, gradient arka planlar ve premium hissiyat |
| **Giriş / Kayıt** | Müşteri veya Satıcı rolü seçerek güvenli giriş |
| **Ana Sayfa** | Aktif mağazaları listeler, çiçek kataloglarına göz at |
| **Arama** | Anlık mağaza filtreleme |
| **Sepet & Ödeme** | Gerçek zamanlı sepet yönetimi, farklı mağaza koruma kuralı |
| **Profil** | Kullanıcı bilgileri, siparişler, adresler, dil/güvenlik ayarları |
| **Satıcı Paneli** | Mağaza açma, çiçek ekleme, vitrin yönetimi |

## 🛠 Teknoloji

- **Flutter** — Cross-platform UI framework
- **Riverpod** — State management
- **GoRouter** — Declarative routing
- **HTTP** — REST API bağlantısı (Spring Boot backend)

## 🚀 Kurulum

```bash
# Bağımlılıkları indir
flutter pub get

# Uygulamayı başlat
flutter run
```

## 🔗 Backend Bağlantısı

Uygulama varsayılan olarak `http://10.0.2.2:8080` (Android emülatör) adresine istek atar.

- Backend çalışmıyorsa **çevrimdışı (fallback) mod** devreye girer ve uygulama yerel verilerle çalışır.
- Gerçek cihazda test ediyorsanız, `auth_provider.dart` dosyasındaki `baseUrl`'i bilgisayarınızın yerel IP adresiyle değiştirin.

## 📁 Proje Yapısı

```
lib/
├── main.dart                    # Tema, Router, Uygulama girişi
├── features/
│   ├── auth/                    # Giriş, Kayıt, Auth Provider
│   ├── catalog/                 # Ana Sayfa, Arama, Mağaza/Çiçek Detay
│   ├── cart/                    # Sepet, Ödeme (Checkout)
│   ├── profile/                 # Profil, Ayarlar
│   └── store/                   # Satıcı Paneli (Dashboard)
```

## 🔒 Güvenlik

- Şifreler `obscureText` ile maskelenir ve minimum 6 karakter zorunluluğu vardır.
- `.gitignore` dosyasına hassas anahtarlar (`*.jks`, `*.env`, `google-services.json`) eklenmiştir.
- Backend tarafında şifreler düz metin olarak saklanır (MVP). Prodüksiyon için **BCrypt** kullanılmalıdır.

## 📄 Lisans

MIT
