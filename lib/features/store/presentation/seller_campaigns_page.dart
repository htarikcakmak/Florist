import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Campaign {
  final String id;
  final String type; // percent, bogo, freeShipping
  final String title;
  final int discount;
  final double minAmount;
  final DateTime startDate;
  final DateTime endDate;
  bool isActive;

  Campaign({required this.id, required this.type, required this.title, this.discount = 0, this.minAmount = 0, required this.startDate, required this.endDate, this.isActive = true});
}

class CampaignNotifier extends Notifier<List<Campaign>> {
  @override
  List<Campaign> build() => [
    Campaign(id: '1', type: 'percent', title: 'Yaz İndirimi', discount: 20, minAmount: 100, startDate: DateTime.now().subtract(const Duration(days: 2)), endDate: DateTime.now().add(const Duration(days: 5)), isActive: true),
    Campaign(id: '2', type: 'freeShipping', title: 'Ücretsiz Kargo', discount: 0, minAmount: 150, startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 7)), isActive: true),
    Campaign(id: '3', type: 'bogo', title: '2 Al 1 Öde - Papatya', discount: 0, minAmount: 0, startDate: DateTime.now().subtract(const Duration(days: 10)), endDate: DateTime.now().subtract(const Duration(days: 3)), isActive: false),
  ];

  void toggle(String id) {
    state = state.map((c) {
      if (c.id == id) c.isActive = !c.isActive;
      return c;
    }).toList();
    state = [...state];
  }

  void addCampaign(Campaign c) => state = [...state, c];
  void removeCampaign(String id) => state = state.where((c) => c.id != id).toList();
}

final campaignProvider = NotifierProvider<CampaignNotifier, List<Campaign>>(() => CampaignNotifier());

class SellerCampaignsPage extends ConsumerStatefulWidget {
  const SellerCampaignsPage({super.key});
  @override
  ConsumerState<SellerCampaignsPage> createState() => _SellerCampaignsPageState();
}

class _SellerCampaignsPageState extends ConsumerState<SellerCampaignsPage> {
  @override
  Widget build(BuildContext context) {
    final campaigns = ref.watch(campaignProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Stack(
      children: [
        campaigns.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_rounded, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('Henüz kampanya yok', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Text('Sağ alttaki butona basarak kampanya oluşturun', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: campaigns.length,
                itemBuilder: (context, index) {
                  final c = campaigns[index];
                  final isExpired = c.endDate.isBefore(DateTime.now());
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isExpired ? Colors.grey.shade300 : c.isActive ? primary.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: _typeColor(c.type).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Icon(_typeIcon(c.type), color: _typeColor(c.type), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 2),
                                  Text(_typeDescription(c), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            if (!isExpired)
                              Switch(
                                value: c.isActive,
                                activeColor: primary,
                                onChanged: (_) => ref.read(campaignProvider.notifier).toggle(c.id),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                                child: Text('Sona Erdi', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatDate(c.startDate)} - ${_formatDate(c.endDate)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                            const Spacer(),
                            if (c.minAmount > 0)
                              Text('Min. ₺${c.minAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

        // FAB: Kampanya Oluştur
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showCreateCampaignSheet(context, primary, ref),
            icon: const Icon(Icons.add),
            label: const Text('Kampanya Oluştur'),
          ),
        ),
      ],
    );
  }

  void _showCreateCampaignSheet(BuildContext context, Color primary, WidgetRef ref) {
    String selectedType = 'percent';
    final discountController = TextEditingController(text: '10');
    final minAmountController = TextEditingController(text: '0');
    final titleController = TextEditingController();
    int durationDays = 7;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Yeni Kampanya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
                  const SizedBox(height: 20),
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Kampanya Adı', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'percent', label: Text('%'), icon: Icon(Icons.percent, size: 16)),
                      ButtonSegment(value: 'bogo', label: Text('2=1'), icon: Icon(Icons.looks_two_rounded, size: 16)),
                      ButtonSegment(value: 'freeShipping', label: Text('Kargo'), icon: Icon(Icons.local_shipping_rounded, size: 16)),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (s) => setSheetState(() => selectedType = s.first),
                  ),
                  const SizedBox(height: 16),
                  if (selectedType == 'percent')
                    TextField(controller: discountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'İndirim Oranı (%)', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: minAmountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minimum Sepet Tutarı (₺)', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: durationDays,
                    decoration: const InputDecoration(labelText: 'Süre', border: OutlineInputBorder()),
                    items: [1, 3, 7, 14, 30].map((d) => DropdownMenuItem(value: d, child: Text('$d gün'))).toList(),
                    onChanged: (v) => setSheetState(() => durationDays = v!),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;
                      ref.read(campaignProvider.notifier).addCampaign(Campaign(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: selectedType,
                        title: titleController.text.trim(),
                        discount: int.tryParse(discountController.text) ?? 0,
                        minAmount: double.tryParse(minAmountController.text) ?? 0,
                        startDate: DateTime.now(),
                        endDate: DateTime.now().add(Duration(days: durationDays)),
                      ));
                      Navigator.pop(ctx);
                    },
                    child: const Text('Kampanyayı Başlat'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'percent': return Colors.green;
      case 'bogo': return Colors.blue;
      case 'freeShipping': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'percent': return Icons.percent_rounded;
      case 'bogo': return Icons.looks_two_rounded;
      case 'freeShipping': return Icons.local_shipping_rounded;
      default: return Icons.campaign;
    }
  }

  String _typeDescription(Campaign c) {
    switch (c.type) {
      case 'percent': return '%${c.discount} indirim';
      case 'bogo': return '2 Al 1 Öde';
      case 'freeShipping': return 'Ücretsiz Kargo';
      default: return '';
    }
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
}
