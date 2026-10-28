import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../presentation/favorite_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<Map<String, dynamic>> _flowers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteFlowers();
  }

  Future<void> _loadFavoriteFlowers() async {
    setState(() => _loading = true);
    // Önce favori ID'lerini yükle
    await ref.read(favoriteProvider.notifier).loadFavorites(1);
    final favIds = ref.read(favoriteProvider).favoriteFlowerIds;

    if (favIds.isEmpty) {
      setState(() { _flowers = []; _loading = false; });
      return;
    }

    // Her favori çiçeği API'den çek
    final List<Map<String, dynamic>> loaded = [];
    for (final id in favIds) {
      try {
        final resp = await http.get(
          Uri.parse('https://flowerist-api.onrender.com/api/flowers/$id'),
        ).timeout(const Duration(seconds: 8));
        if (resp.statusCode == 200) {
          loaded.add(jsonDecode(resp.body));
        }
      } catch (_) {}
    }
    setState(() { _flowers = loaded; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);
    final favState = ref.watch(favoriteProvider);

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
            child: Text('${_flowers.length}', style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ]),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _flowers.isEmpty
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
              : RefreshIndicator(
                  onRefresh: _loadFavoriteFlowers,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72,
                    ),
                    itemCount: _flowers.length,
                    itemBuilder: (context, index) {
                      final flower = _flowers[index];
                      final flowerId = flower['id']?.toString() ?? '';
                      final isFav = favState.favoriteFlowerIds.contains(flowerId);
                      return _FavoriteCard(
                        flower: flower, cardColor: cardColor, primary: primary,
                        isFavorite: isFav,
                        onToggle: () async {
                          await ref.read(favoriteProvider.notifier).toggleFavorite(flowerId, 1);
                          if (!isFav) return;
                          setState(() => _flowers.removeAt(index));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${flower['name'] ?? 'Çiçek'} favorilerden çıkarıldı'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ));
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> flower;
  final Color cardColor, primary;
  final bool isFavorite;
  final VoidCallback onToggle;

  const _FavoriteCard({required this.flower, required this.cardColor, required this.primary, required this.isFavorite, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final name = flower['name'] ?? 'Çiçek';
    final price = (flower['price'] ?? 0).toDouble();
    final storeName = flower['storeName'] ?? flower['store'] ?? '';
    final category = flower['category'] ?? '';
    final imageUrl = flower['imageUrl'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120, width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary.withOpacity(0.08), primary.withOpacity(0.03)]),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.local_florist_rounded, size: 48, color: primary.withOpacity(0.25))),
                      )
                    : Icon(Icons.local_florist_rounded, size: 48, color: primary.withOpacity(0.25)),
              ),
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                    child: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFavorite ? Colors.red : Colors.grey.shade400, size: 18),
                  ),
                ),
              ),
              if (category.isNotEmpty)
                Positioned(
                  bottom: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: primary.withOpacity(0.85), borderRadius: BorderRadius.circular(8)),
                    child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (storeName.isNotEmpty) Text(storeName, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  const Spacer(),
                  Row(children: [
                    Text('₺${price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: primary)),
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
