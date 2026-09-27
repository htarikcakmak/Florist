import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/favorite_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);
    final favState = ref.watch(favoriteProvider);
    final favIds = favState.favoriteFlowerIds.toList();

    // Demo favori çiçekler
    final demoFavorites = [
      _FavFlower(id: '1', name: 'Kırmızı Gül Buketi', price: 149.90, category: 'Buket', store: 'Çiçek Bahçesi'),
      _FavFlower(id: '2', name: 'Beyaz Orkide', price: 89.90, category: 'Saksı', store: 'Orkide Dünyası'),
      _FavFlower(id: '3', name: 'Papatya Aranjmanı', price: 69.90, category: 'Aranjman', store: 'Çiçek Bahçesi'),
      _FavFlower(id: '4', name: 'Gelin Buketi Premium', price: 299.90, category: 'Gelin', store: 'Gelin Çiçekleri'),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: primary), onPressed: () => context.pop()),
        title: Row(children: [
          Text('Favorilerim', style: TextStyle(fontWeight: FontWeight.w900, color: primary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('${demoFavorites.length}', style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ]),
        centerTitle: true,
      ),
      body: demoFavorites.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), shape: BoxShape.circle),
                child: Icon(Icons.favorite_outline_rounded, size: 56, color: Colors.red.withOpacity(0.4)),
              ),
              const SizedBox(height: 20),
              Text('Henüz favori yok', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 8),
              Text('Beğendiğin çiçeklere ❤️ bas!', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            ]))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: demoFavorites.length,
              itemBuilder: (context, index) {
                final flower = demoFavorites[index];
                return _FavoriteCard(flower: flower, cardColor: cardColor, primary: primary, ref: ref);
              },
            ),
    );
  }
}

class _FavFlower {
  final String id, name, category, store;
  final double price;
  _FavFlower({required this.id, required this.name, required this.price, required this.category, required this.store});
}

class _FavoriteCard extends StatelessWidget {
  final _FavFlower flower;
  final Color cardColor, primary;
  final WidgetRef ref;
  const _FavoriteCard({required this.flower, required this.cardColor, required this.primary, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Görsel + kalp
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary.withOpacity(0.08), primary.withOpacity(0.03)]),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Icon(Icons.local_florist_rounded, size: 48, color: primary.withOpacity(0.25)),
              ),
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: () {
                    ref.read(favoriteProvider.notifier).toggleFavorite(flower.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${flower.name} favorilerden çıkarıldı'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                    child: const Icon(Icons.favorite_rounded, color: Colors.red, size: 18),
                  ),
                ),
              ),
              // Kategori badge
              Positioned(
                bottom: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: primary.withOpacity(0.85), borderRadius: BorderRadius.circular(8)),
                  child: Text(flower.category, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          // Bilgiler
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(flower.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(flower.store, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  const Spacer(),
                  Row(children: [
                    Text('₺${flower.price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: primary)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.add_shopping_cart_rounded, size: 16, color: primary),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
