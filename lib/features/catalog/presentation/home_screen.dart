import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/auth_provider.dart';
import 'marketplace_provider.dart';
import '../domain/vendor.dart';

Widget _buildImage(String path, {double? width, double? height}) {
  if (path.isEmpty) return Container(width: width, height: height, color: Colors.grey.shade200, child: const Icon(Icons.local_florist_rounded, size: 40, color: Colors.grey));
  return kIsWeb ? Image.network(path, width: width, height: height, fit: BoxFit.cover) : Image.file(File(path), width: width, height: height, fit: BoxFit.cover);
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final PageController _bannerController = PageController(viewportFraction: 0.9);
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  @override
  void dispose() { _animController.dispose(); _bannerController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final activeVendors = ref.watch(marketplaceProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // Özel AppBar
          SliverAppBar(
            floating: true,
            backgroundColor: bgColor,
            elevation: 0,
            title: Row(
              children: [
                Icon(Icons.local_florist_rounded, color: primary, size: 28),
                const SizedBox(width: 8),
                Text('Flowerist', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: primary, letterSpacing: -1)),
              ],
            ),
            actions: [
              IconButton(
                icon: Badge(label: const Text('2', style: TextStyle(fontSize: 10)), child: Icon(Icons.notifications_none_rounded, color: primary)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Hero Banner Slider
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _animController, curve: Curves.easeOut),
              child: Column(
                children: [
                  SizedBox(
                    height: 170,
                    child: PageView(
                      controller: _bannerController,
                      onPageChanged: (i) => setState(() => _bannerIndex = i),
                      children: [
                        _BannerCard(
                          gradient: [primary, primary.withOpacity(0.7)],
                          icon: Icons.local_offer_rounded,
                          title: 'Yaz Koleksiyonu 🌸',
                          subtitle: 'Sezon çiçeklerinde %30\'a varan indirim',
                          action: 'Keşfet',
                        ),
                        _BannerCard(
                          gradient: [Colors.orange.shade700, Colors.amber.shade500],
                          icon: Icons.delivery_dining_rounded,
                          title: 'Ücretsiz Kargo 🚚',
                          subtitle: '₺150 ve üzeri siparişlerde kargo bedava',
                          action: 'Sipariş Ver',
                        ),
                        _BannerCard(
                          gradient: [Colors.purple.shade700, Colors.pink.shade400],
                          icon: Icons.favorite_rounded,
                          title: 'Sevgiliye Özel 💐',
                          subtitle: 'En romantik buketler özel fiyatlarla',
                          action: 'İncele',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Banner dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _bannerIndex == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _bannerIndex == i ? primary : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),

          // Kategori Chip'leri
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategoriler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(emoji: '🌹', label: 'Güller', color: Colors.red.shade100, textColor: Colors.red.shade700),
                        _CategoryChip(emoji: '🌸', label: 'Orkide', color: Colors.purple.shade50, textColor: Colors.purple.shade700),
                        _CategoryChip(emoji: '🌻', label: 'Papatya', color: Colors.amber.shade50, textColor: Colors.amber.shade800),
                        _CategoryChip(emoji: '💐', label: 'Buket', color: Colors.green.shade50, textColor: Colors.green.shade700),
                        _CategoryChip(emoji: '🪴', label: 'Saksı', color: Colors.teal.shade50, textColor: Colors.teal.shade700),
                        _CategoryChip(emoji: '👰', label: 'Gelin', color: Colors.pink.shade50, textColor: Colors.pink.shade700),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mağazalar Başlığı
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  Text('Yakındaki Mağazalar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary)),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: Text('Tümü', style: TextStyle(color: primary, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),

          // Mağaza Listesi
          activeVendors.isEmpty
              ? SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Icon(Icons.storefront_outlined, size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('Henüz aktif mağaza yok', style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Satıcıların gelmesini bekliyoruz! 🌸', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vendor = activeVendors[index];
                      final delay = index * 0.15;
                      return SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
                            .animate(CurvedAnimation(parent: _animController, curve: Interval(delay.clamp(0, 1), (delay + 0.5).clamp(0, 1), curve: Curves.easeOutCubic))),
                        child: FadeTransition(
                          opacity: CurvedAnimation(parent: _animController, curve: Interval(delay.clamp(0, 1), (delay + 0.5).clamp(0, 1))),
                          child: _VendorCard(vendor: vendor, cardColor: cardColor, primary: primary),
                        ),
                      );
                    },
                    childCount: activeVendors.length,
                  ),
                ),

          // Alt boşluk (navbar için)
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// --- Banner Kartı ---
class _BannerCard extends StatelessWidget {
  final List<Color> gradient;
  final IconData icon;
  final String title, subtitle, action;
  const _BannerCard({required this.gradient, required this.icon, required this.title, required this.subtitle, required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: gradient.first.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                  child: Text(action, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.white.withOpacity(0.3), size: 64),
        ],
      ),
    );
  }
}

// --- Kategori Chip ---
class _CategoryChip extends StatelessWidget {
  final String emoji, label;
  final Color color, textColor;
  const _CategoryChip({required this.emoji, required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 13)),
        ],
      ),
    );
  }
}

// --- Mağaza Kartı (Glassmorphism) ---
class _VendorCard extends StatelessWidget {
  final Vendor vendor;
  final Color cardColor, primary;
  const _VendorCard({required this.vendor, required this.cardColor, required this.primary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/vendor', extra: vendor.name),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kapak foto
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildImage(vendor.coverPath, height: 140, width: double.infinity),
                ),
                // Rating badge
                Positioned(
                  top: 12, right: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 3),
                            Text(vendor.rating > 0 ? vendor.rating.toStringAsFixed(1) : 'Yeni', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Logo
                Positioned(
                  bottom: -20, left: 16,
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: cardColor, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                    child: CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade200, child: Icon(Icons.storefront_rounded, color: primary, size: 24)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(80, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendor.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoTag(icon: Icons.access_time_rounded, text: vendor.deliveryTime, color: Colors.blue),
                      const SizedBox(width: 10),
                      _InfoTag(
                        icon: Icons.delivery_dining_rounded,
                        text: vendor.shippingCost == 0 ? 'Ücretsiz' : '₺${vendor.shippingCost.toStringAsFixed(0)}',
                        color: vendor.shippingCost == 0 ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoTag({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}