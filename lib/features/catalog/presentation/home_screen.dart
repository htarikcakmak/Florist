import 'dart:io';
import 'package:flutter/foundation.dart'; // YENİ: Web mi Mobil mi olduğunu anlayan kütüphane
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/auth_provider.dart';
import 'marketplace_provider.dart';

// --- TEMİZ KOD YARDIMCILARI (Helper Functions) ---
// Eğer Chrome'daysak internetten okur, Telefondaysak dosyadan okur. Çökmeyi engeller.
Widget buildResponsiveImage(String path, {double? width, double? height}) {
  return kIsWeb
      ? Image.network(path, width: width, height: height, fit: BoxFit.cover)
      : Image.file(File(path), width: width, height: height, fit: BoxFit.cover);
}

ImageProvider getResponsiveImageProvider(String path) {
  return kIsWeb ? NetworkImage(path) : FileImage(File(path)) as ImageProvider;
}
// -------------------------------------------------

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeVendors = ref.watch(marketplaceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Yeni arka plan rengi
      appBar: AppBar(
        title: const Text('Flowerist', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: activeVendors.isEmpty
          ? const Center(
              child: Text(
                'Şu an aktif hiçbir mağaza yok.\nSatıcıların gelmesini bekliyoruz!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeVendors.length,
              itemBuilder: (context, index) {
                final vendor = activeVendors[index];
                return GestureDetector(
                  onTap: () {
                    context.push('/vendor', extra: vendor.name);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ÇİZİMİNDEKİ TASARIM BURADA
                        Stack(
                          children: [
                            // Kapak Fotoğrafı
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: buildResponsiveImage(vendor.coverPath, height: 160, width: double.infinity),
                            ),
                            // Sol Alt Köşedeki Yuvarlak Logo
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: getResponsiveImageProvider(vendor.logoPath),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendor.name,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(vendor.deliveryTime, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 16),
                                  Icon(Icons.delivery_dining, size: 16, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    vendor.shippingCost == 0 ? 'Ücretsiz Teslimat' : 'Kargo: ₺${vendor.shippingCost.toStringAsFixed(2)}', 
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
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
              },
            ),
    );
  }
}