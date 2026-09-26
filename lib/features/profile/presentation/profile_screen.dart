import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../theme/presentation/theme_provider.dart';
import '../../favorite/presentation/favorite_provider.dart';
import '../../order/presentation/order_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);

    final email = authState.email ?? 'kullanici@flowerist.com';

    String displayName;
    if (authState.name != null && authState.name!.trim().isNotEmpty) {
      displayName = authState.name!.trim();
    } else {
      final namePart = email.split('@').first;
      displayName = namePart[0].toUpperCase() + namePart.substring(1);
    }

    final favCount = ref.watch(favoriteProvider).favoriteFlowerIds.length;
    final orderCount = ref.watch(orderProvider).orders.length;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // Profil Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 20, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, primary.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(displayName[0], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(email, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                authState.role == UserRole.seller ? '🏪 Satıcı' : '🛍️ Müşteri',
                                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // İstatistik kartları
                  Row(
                    children: [
                      _StatMini(icon: Icons.shopping_bag_rounded, label: 'Sipariş', value: '$orderCount', cardColor: Colors.white.withOpacity(0.15)),
                      const SizedBox(width: 12),
                      _StatMini(icon: Icons.favorite_rounded, label: 'Favori', value: '$favCount', cardColor: Colors.white.withOpacity(0.15)),
                      const SizedBox(width: 12),
                      _StatMini(icon: Icons.location_on_rounded, label: 'Adres', value: '2', cardColor: Colors.white.withOpacity(0.15)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Menü öğeleri
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _MenuCard(
                    cardColor: cardColor,
                    items: [
                      _MenuItem(icon: Icons.shopping_bag_rounded, label: 'Siparişlerim', color: Colors.blue, onTap: () {
                        _showOrdersSheet(context, primary, ref);
                      }),
                      _MenuItem(icon: Icons.favorite_rounded, label: 'Favorilerim', color: Colors.red, badge: favCount > 0 ? '$favCount' : null, onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$favCount favori ürün'), backgroundColor: primary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                      }),
                      _MenuItem(icon: Icons.location_on_rounded, label: 'Adreslerim', color: Colors.orange, onTap: () {
                        _showAddressesSheet(context, primary);
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    cardColor: cardColor,
                    items: [
                      _MenuItem(icon: Icons.palette_rounded, label: 'Tema', color: Colors.purple, trailing: _ThemeSelector(ref: ref, primary: primary)),
                      _MenuItem(icon: Icons.language_rounded, label: 'Dil', color: Colors.teal, subtitle: 'Türkçe', onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Dil: Türkçe'), backgroundColor: primary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                      }),
                      _MenuItem(icon: Icons.security_rounded, label: 'Güvenlik', color: Colors.blueGrey, onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Hesabınız güvenli 🔒'), backgroundColor: primary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                      }),
                      _MenuItem(icon: Icons.help_outline_rounded, label: 'Yardım', color: Colors.cyan, onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Çıkış butonu
                  Container(
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.logout_rounded, color: Colors.red, size: 22),
                      ),
                      title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.red),
                      onTap: () {
                        ref.read(authProvider.notifier).logout();
                        context.go('/login');
                      },
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrdersSheet(BuildContext context, Color primary, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Siparişlerim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
            const SizedBox(height: 16),
            const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Orkide Saksı', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Teslim Edildi — 3 gün önce'), trailing: Text('₺89.90', style: TextStyle(fontWeight: FontWeight.bold))),
            const Divider(),
            const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.local_shipping_rounded, color: Colors.blue), title: Text('Gül Buketi', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Kargoda — Bugün teslim'), trailing: Text('₺149.90', style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddressesSheet(BuildContext context, Color primary) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Text('Adreslerim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
              const Spacer(),
              IconButton(onPressed: () {}, icon: Icon(Icons.add_circle, color: primary)),
            ]),
            const SizedBox(height: 12),
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.home_rounded, color: primary, size: 28), title: const Text('Ev', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Ataşehir Bulvarı No:12 D:4, İstanbul')),
            const Divider(),
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.business_rounded, color: Colors.grey.shade500, size: 28), title: const Text('İş', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Maslak Meydan Sok. No:5, İstanbul')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color cardColor;
  const _StatMini({required this.icon, required this.label, required this.value, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final Color cardColor;
  final List<_MenuItem> items;
  const _MenuCard({required this.cardColor, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: item.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: item.subtitle != null ? Text(item.subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)) : null,
              trailing: item.trailing ?? (item.badge != null
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: item.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(item.badge!, style: TextStyle(color: item.color, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                    ])
                  : Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400)),
              onTap: item.onTap,
            ),
            if (i < items.length - 1) Divider(height: 1, indent: 60, color: Colors.grey.shade200),
          ]);
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final String? subtitle;
  final String? badge;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.label, required this.color, this.subtitle, this.badge, this.trailing, this.onTap});
}

class _ThemeSelector extends StatelessWidget {
  final WidgetRef ref;
  final Color primary;
  const _ThemeSelector({required this.ref, required this.primary});

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(themeProvider);
    return SizedBox(
      height: 36,
      child: SegmentedButton<AppThemeMode>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: primary.withOpacity(0.15),
          selectedForegroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          visualDensity: VisualDensity.compact,
        ),
        segments: const [
          ButtonSegment(value: AppThemeMode.light, icon: Icon(Icons.wb_sunny_rounded, size: 16)),
          ButtonSegment(value: AppThemeMode.dark, icon: Icon(Icons.dark_mode_rounded, size: 16)),
          ButtonSegment(value: AppThemeMode.system, icon: Icon(Icons.phone_android_rounded, size: 16)),
        ],
        selected: {current},
        onSelectionChanged: (s) => ref.read(themeProvider.notifier).setTheme(s.first),
      ),
    );
  }
}
