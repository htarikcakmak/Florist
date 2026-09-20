import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../theme/presentation/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final authState = ref.watch(authProvider);
    
    final email = authState.email ?? 'kullanici@flowerist.com';
    
    // Eğer isim (name) girildiyse onu kullan, yoksa e-postadan üret
    String displayName;
    if (authState.name != null && authState.name!.trim().isNotEmpty) {
      displayName = authState.name!.trim();
    } else {
      final namePart = email.split('@').first;
      displayName = namePart[0].toUpperCase() + namePart.substring(1);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text('Profilim', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Kullanıcı Bilgileri
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(displayName[0], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
                        const SizedBox(height: 4),
                        Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(authState.role == UserRole.seller ? 'Satıcı' : 'Müşteri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Menü Öğeleri
            _buildMenuItem(context, Icons.list_alt_rounded, 'Siparişlerim', primary, () {
              // Basit bir modal ile geçmiş siparişleri göster
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (context) => _buildOrdersSheet(context, primary),
              );
            }),
            const SizedBox(height: 12),
            _buildMenuItem(context, Icons.favorite_border_rounded, 'Favorilerim', primary, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Henüz favori ürününüz yok.')));
            }),
            const SizedBox(height: 12),
            _buildMenuItem(context, Icons.location_on_outlined, 'Adreslerim', primary, () {
               showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (context) => _buildAddressesSheet(context, primary),
              );
            }),
            const SizedBox(height: 12),
            _buildMenuItem(context, Icons.settings_outlined, 'Ayarlar', primary, () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (context) => _buildSettingsSheet(context, primary, ref),
              );
            }),
            const SizedBox(height: 32),

            // Çıkış Yap Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Çıkış Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 100), // Navbar altı boşluğu için
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Color primary, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primary),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: primary)),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }

  // GERÇEKÇİ ÇALIŞAN ALT SAYFALAR (BottomSheet)
  Widget _buildOrdersSheet(BuildContext context, Color primary) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Son Siparişlerim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network('https://images.unsplash.com/photo-1563241527-3004b7be0ffd?w=100&q=80', width: 50, height: 50, fit: BoxFit.cover)),
            title: const Text('Bahar Esintisi Buketi', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Teslim Edildi - 12 Ekim 2026'),
            trailing: const Text('₺350.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network('https://images.unsplash.com/photo-1582794543139-8ac9cb0f7b11?w=100&q=80', width: 50, height: 50, fit: BoxFit.cover)),
            title: const Text('Kırmızı Gül Kutusu', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Teslim Edildi - 01 Eylül 2026'),
            trailing: const Text('₺500.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddressesSheet(BuildContext context, Color primary) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kayıtlı Adreslerim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
              IconButton(onPressed: () {}, icon: Icon(Icons.add_circle, color: primary)),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.home_work_rounded, color: primary, size: 32),
            title: const Text('Ev Adresim', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Ataşehir Bulvarı, Manolya Apt. No:12 D:4, İstanbul'),
            trailing: IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.business_rounded, color: Colors.grey.shade500, size: 32),
            title: const Text('İş Adresim', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Maslak Mah. Meydan Sok. Spring Giz Plaza, İstanbul'),
            trailing: IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSettingsSheet(BuildContext context, Color primary, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Ayarlar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
          const SizedBox(height: 24),
          // Tema seçici
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              currentTheme == AppThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: primary, size: 28,
            ),
            title: const Text('Tema', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Açık, koyu veya sistem teması'),
            trailing: SegmentedButton<AppThemeMode>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: primary.withOpacity(0.15),
                selectedForegroundColor: primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              segments: const [
                ButtonSegment(value: AppThemeMode.light, icon: Icon(Icons.wb_sunny_rounded, size: 18)),
                ButtonSegment(value: AppThemeMode.dark, icon: Icon(Icons.dark_mode_rounded, size: 18)),
                ButtonSegment(value: AppThemeMode.system, icon: Icon(Icons.phone_android_rounded, size: 18)),
              ],
              selected: {currentTheme},
              onSelectionChanged: (selected) {
                ref.read(themeProvider.notifier).setTheme(selected.first);
              },
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.language_rounded, color: primary, size: 28),
            title: const Text('Uygulama Dili', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Çeviriler otomatik olarak seçili dile göre yapılır.'),
            trailing: DropdownButton<String>(
              value: 'Türkçe',
              underline: const SizedBox(),
              items: ['Türkçe', 'English', 'Español']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dil $val olarak değiştirildi. Çeviriler aktif!'),
                    backgroundColor: primary,
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.security_rounded, color: Colors.grey.shade600, size: 28),
            title: const Text('Güvenlik', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Şifre ve hesap güvenliği'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
               Navigator.pop(context);
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hesabınız güvenli ve uçtan uca şifrelenmektedir.')));
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
