import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdItem {
  final String id;
  final String flowerName;
  final int durationDays;
  final DateTime startDate;
  final double cost;
  bool isActive;

  AdItem({required this.id, required this.flowerName, required this.durationDays, required this.startDate, this.cost = 0, this.isActive = true});

  DateTime get endDate => startDate.add(Duration(days: durationDays));
  bool get isExpired => endDate.isBefore(DateTime.now());
  int get remainingDays => endDate.difference(DateTime.now()).inDays;
}

class AdNotifier extends Notifier<List<AdItem>> {
  @override
  List<AdItem> build() => [
    AdItem(id: '1', flowerName: 'Kırmızı Gül Buketi', durationDays: 3, startDate: DateTime.now().subtract(const Duration(days: 1)), cost: 29.90),
    AdItem(id: '2', flowerName: 'Orkide Saksı Çiçeği', durationDays: 7, startDate: DateTime.now().subtract(const Duration(days: 2)), cost: 59.90),
  ];

  void addAd(AdItem ad) => state = [...state, ad];
  void removeAd(String id) => state = state.where((a) => a.id != id).toList();
}

final adProvider = NotifierProvider<AdNotifier, List<AdItem>>(() => AdNotifier());

class SellerAdsPage extends ConsumerWidget {
  const SellerAdsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(adProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bilgi kartı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.orange.shade600]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.campaign_rounded, color: Colors.white, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Çiçeğinizi Öne Çıkarın', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Ürünlerinizi ana sayfada daha fazla müşteriye gösterin', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Fiyatlandırma
              Text('Reklam Paketleri', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _PriceCard(days: 1, price: '₺9.90', color: Colors.blue, cardColor: cardColor)),
                  const SizedBox(width: 10),
                  Expanded(child: _PriceCard(days: 3, price: '₺29.90', color: Colors.green, cardColor: cardColor, isBest: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _PriceCard(days: 7, price: '₺59.90', color: Colors.purple, cardColor: cardColor)),
                ],
              ),
              const SizedBox(height: 24),

              // Aktif reklamlar
              Text('Aktif Reklamlarınız', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 12),

              if (ads.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Icon(Icons.ad_units_rounded, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text('Henüz reklam yok', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              else
                ...ads.map((ad) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ad.isExpired ? Colors.grey.shade300 : primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.local_florist_rounded, color: primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ad.flowerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              ad.isExpired ? 'Sona erdi' : '${ad.remainingDays} gün kaldı',
                              style: TextStyle(fontSize: 12, color: ad.isExpired ? Colors.grey : Colors.green, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Text('₺${ad.cost.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
                    ],
                  ),
                )),
              const SizedBox(height: 80),
            ],
          ),
        ),

        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showCreateAdSheet(context, primary, ref),
            icon: const Icon(Icons.add),
            label: const Text('Reklam Oluştur'),
          ),
        ),
      ],
    );
  }

  void _showCreateAdSheet(BuildContext context, Color primary, WidgetRef ref) {
    final nameController = TextEditingController();
    int selectedDays = 3;
    final prices = {1: 9.90, 3: 29.90, 7: 59.90};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Çiçeği Öne Çıkar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
                const SizedBox(height: 20),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Çiçek Adı', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 1, label: Text('1 Gün')),
                    ButtonSegment(value: 3, label: Text('3 Gün')),
                    ButtonSegment(value: 7, label: Text('7 Gün')),
                  ],
                  selected: {selectedDays},
                  onSelectionChanged: (s) => setSheetState(() => selectedDays = s.first),
                ),
                const SizedBox(height: 16),
                Text('Ücret: ₺${prices[selectedDays]!.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    ref.read(adProvider.notifier).addAd(AdItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      flowerName: nameController.text.trim(),
                      durationDays: selectedDays,
                      startDate: DateTime.now(),
                      cost: prices[selectedDays]!,
                    ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Reklamı Başlat'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        });
      },
    );
  }
}

class _PriceCard extends StatelessWidget {
  final int days;
  final String price;
  final Color color, cardColor;
  final bool isBest;
  const _PriceCard({required this.days, required this.price, required this.color, required this.cardColor, this.isBest = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isBest ? color : Colors.grey.shade200, width: isBest ? 2 : 1),
      ),
      child: Column(
        children: [
          if (isBest) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
            child: const Text('Popüler', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          Text('$days Gün', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
