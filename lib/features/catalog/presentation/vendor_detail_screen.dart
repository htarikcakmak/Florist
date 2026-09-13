import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../store/presentation/store_provider.dart';
import '../../cart/presentation/cart_screen.dart';
import 'flower_detail_screen.dart';

// --- TEMİZ KOD YARDIMCISI ---
Widget buildResponsiveImage(String path, {double? width, double? height}) {
  return kIsWeb
      ? Image.network(path, width: width, height: height, fit: BoxFit.cover)
      : Image.file(File(path), width: width, height: height, fit: BoxFit.cover);
}
// -----------------------------

class VendorDetailScreen extends ConsumerWidget {
  final String vendorName;
  const VendorDetailScreen({super.key, required this.vendorName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // İleride burası sadece o mağazaya ait çiçekleri çekecek şekilde güncellenecek
    final catalogFlowers = ref.watch(storeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(vendorName, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        centerTitle: true,
        
        // YENİ YAMA: Sağ üst köşedeki Sepet İkonu ve Kırmızı Rozet (Badge)
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final cartItems = ref.watch(cartProvider).items;
              // Sepetteki toplam ürün sayısını hesaplar
              final itemCount = cartItems.fold(0, (sum, item) => sum + item.quantity);
              
              return Stack(
                alignment: Alignment.center,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).colorScheme.primary, size: 28),
                    onPressed: () {
                      // Sepete tıklandığında CartScreen'e yönlendirir
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                    },
                  ),
                  // Eğer sepette ürün varsa kırmızı bir baloncuk çıkar
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          itemCount.toString(), 
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8), // Sağdan hafif boşluk
        ],
      ),
      body: catalogFlowers.isEmpty
          ? const Center(
              child: Text(
                'Bu mağazada henüz çiçek bulunmuyor.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: catalogFlowers.length,
              itemBuilder: (context, index) {
                final flower = catalogFlowers[index];
                
                // YENİ YAMA: Çiçeğe tıklayınca Trendyol stili detay sayfasına götür
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlowerDetailScreen(
                          flower: flower,
                          vendorName: vendorName,
                          storeFlowers: catalogFlowers, // Öneriler için listeyi gönderdik
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    // ... (Buradan sonrası senin mevcut tasarımın, aynen devam etsin)
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: buildResponsiveImage(
                              flower.imagePath,
                              width: 80,
                              height: 80,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  flower.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  flower.category,
                                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₺${flower.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              final added = ref.read(cartProvider.notifier).addItem(flower, vendorName);
                              if (added) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            '${flower.name} sepete eklendi!',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF34C759),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    margin: const EdgeInsets.all(16),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Farklı Mağaza'),
                                    content: Text(
                                      'Sepetinizde başka bir mağazaya ait ürünler var. Sepeti temizleyip $vendorName mağazasından devam etmek ister misiniz?',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('İptal'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: const Text('Sepeti Temizle', style: TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          ref.read(cartProvider.notifier).clearCartAndAdd(flower, vendorName);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Sepet yenilendi ve ürün eklendi!'),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_shopping_cart_rounded, color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      );
  }
}
