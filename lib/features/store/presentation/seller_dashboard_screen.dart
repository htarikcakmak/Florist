import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/auth_provider.dart';
import '../../catalog/domain/vendor.dart';
import '../../catalog/presentation/marketplace_provider.dart';
import '../../review/presentation/review_provider.dart';
import '../../review/domain/review.dart';
import 'store_provider.dart';
import 'dashboard_home_page.dart';
import 'seller_orders_page.dart';
import 'seller_reports_page.dart';
import 'seller_campaigns_page.dart';
import 'seller_ads_page.dart';

// --- TEMİZ KOD YARDIMCILARI ---
Widget buildResponsiveImage(String path, {double? width, double? height}) {
  return kIsWeb
      ? Image.network(path, width: width, height: height, fit: BoxFit.cover)
      : Image.file(File(path), width: width, height: height, fit: BoxFit.cover);
}

ImageProvider getResponsiveImageProvider(String path) {
  return kIsWeb ? NetworkImage(path) : FileImage(File(path)) as ImageProvider;
}
// -----------------------------

class StoreProfileNotifier extends Notifier<Vendor?> {
  @override
  Vendor? build() => null;
  void setStore(Vendor vendor) => state = vendor;
}
final myStoreProfileProvider = NotifierProvider<StoreProfileNotifier, Vendor?>(() => StoreProfileNotifier());

class SellerDashboardScreen extends ConsumerStatefulWidget {
  const SellerDashboardScreen({super.key});
  @override
  ConsumerState<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends ConsumerState<SellerDashboardScreen> {
  int _selectedPage = 0;
  bool _isStoreOpen = true;

  static const _pageTitles = [
    'Ana Sayfa',
    'Siparişler',
    'Raporlar',
    'Yorumlar',
    'Kampanyalar',
    'Reklam',
    'Ürün Yönetimi',
  ];

  static const _pageIcons = [
    Icons.dashboard_rounded,
    Icons.shopping_bag_rounded,
    Icons.bar_chart_rounded,
    Icons.star_rounded,
    Icons.campaign_rounded,
    Icons.ads_click_rounded,
    Icons.local_florist_rounded,
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reviewProvider.notifier).loadStoreReviews(0));
  }

  @override
  Widget build(BuildContext context) {
    final myStoreProfile = ref.watch(myStoreProfileProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (myStoreProfile == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF2F2F7),
        appBar: AppBar(title: const Text('Mağaza Kurulumu')),
        body: const _StoreSetupForm(),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(_pageTitles[_selectedPage]),
        actions: [
          // Açık/Kapalı toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _isStoreOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: _isStoreOpen ? Colors.green : Colors.red, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(_isStoreOpen ? 'Açık' : 'Kapalı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _isStoreOpen ? Colors.green : Colors.red)),
                const SizedBox(width: 4),
                SizedBox(
                  height: 24,
                  child: Switch(
                    value: _isStoreOpen,
                    activeColor: Colors.green,
                    onChanged: (v) => setState(() => _isStoreOpen = v),
                  ),
                ),
              ],
            ),
          ),
          // Bildirim ikonu
          IconButton(
            icon: Badge(
              label: const Text('3', style: TextStyle(fontSize: 10)),
              child: Icon(Icons.notifications_rounded, color: primary),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('3 yeni bildirim 🔔'), backgroundColor: primary, behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              );
            },
          ),
        ],
      ),

      // Drawer
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Mağaza profil başlığı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, primary.withOpacity(0.7)]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: _safeImageProvider(myStoreProfile.logoPath),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(myStoreProfile.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(width: 7, height: 7, decoration: BoxDecoration(color: _isStoreOpen ? Colors.greenAccent : Colors.red.shade300, shape: BoxShape.circle)),
                                  const SizedBox(width: 4),
                                  Text(_isStoreOpen ? 'Açık' : 'Kapalı', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Performansınızı İzleyin
              _DrawerSection(title: 'Performansınızı İzleyin'),
              _DrawerItem(index: 0, selected: _selectedPage, icon: _pageIcons[0], label: _pageTitles[0], primary: primary, onTap: () => _selectPage(0)),
              _DrawerItem(index: 1, selected: _selectedPage, icon: _pageIcons[1], label: _pageTitles[1], primary: primary, onTap: () => _selectPage(1), badge: '3'),
              _DrawerItem(index: 2, selected: _selectedPage, icon: _pageIcons[2], label: _pageTitles[2], primary: primary, onTap: () => _selectPage(2)),
              _DrawerItem(index: 3, selected: _selectedPage, icon: _pageIcons[3], label: _pageTitles[3], primary: primary, onTap: () => _selectPage(3)),

              const SizedBox(height: 4),
              _DrawerSection(title: 'İşletmenizi Büyütün'),
              _DrawerItem(index: 4, selected: _selectedPage, icon: _pageIcons[4], label: _pageTitles[4], primary: primary, onTap: () => _selectPage(4)),
              _DrawerItem(index: 5, selected: _selectedPage, icon: _pageIcons[5], label: _pageTitles[5], primary: primary, onTap: () => _selectPage(5)),

              const SizedBox(height: 4),
              _DrawerSection(title: 'İşletmenizi Yönetin'),
              _DrawerItem(index: 6, selected: _selectedPage, icon: _pageIcons[6], label: _pageTitles[6], primary: primary, onTap: () => _selectPage(6)),

              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      body: _buildPage(),
    );
  }

  void _selectPage(int index) {
    setState(() => _selectedPage = index);
    Navigator.pop(context); // Drawer kapat
  }

  Widget _buildPage() {
    switch (_selectedPage) {
      case 0: return const DashboardHomePage();
      case 1: return const SellerOrdersPage();
      case 2: return const SellerReportsPage();
      case 3: return _buildReviewsPage();
      case 4: return const SellerCampaignsPage();
      case 5: return const SellerAdsPage();
      case 6: return _buildProductsPage();
      default: return const DashboardHomePage();
    }
  }

  ImageProvider? _safeImageProvider(String path) {
    try {
      return kIsWeb ? NetworkImage(path) : FileImage(File(path)) as ImageProvider;
    } catch (_) {
      return null;
    }
  }

  // Yorumlar sayfası (mevcut koddan taşındı)
  Widget _buildReviewsPage() {
    final reviewState = ref.watch(reviewProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    if (reviewState.isLoading) return const Center(child: CircularProgressIndicator());

    if (reviewState.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Henüz yorum yok', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    final avgRating = reviewState.reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviewState.reviews.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Ortalama puan kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(avgRating.toStringAsFixed(1), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primary)),
                    Row(children: List.generate(5, (i) => Icon(i < avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber, size: 18))),
                    const SizedBox(height: 4),
                    Text('${reviewState.reviews.length} yorum', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      final count = reviewState.reviews.where((r) => r.rating == star).length;
                      final ratio = count / reviewState.reviews.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$star', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: ratio, backgroundColor: Colors.grey.shade200, color: primary, minHeight: 6))),
                            const SizedBox(width: 8),
                            SizedBox(width: 20, child: Text('$count', style: TextStyle(fontSize: 11, color: Colors.grey.shade500))),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Yorum listesi
          ...reviewState.reviews.map((review) {
            final timeAgo = DateTime.now().difference(review.createdAt);
            String timeText = timeAgo.inDays > 0 ? '${timeAgo.inDays} gün önce' : timeAgo.inHours > 0 ? '${timeAgo.inHours} saat önce' : 'Az önce';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 18, backgroundColor: primary.withOpacity(0.15), child: Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?', style: TextStyle(color: primary, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(timeText, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ])),
                      Row(children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded, color: i < review.rating ? Colors.amber : Colors.grey.shade300, size: 16))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(review.comment, style: const TextStyle(fontSize: 14, height: 1.4)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Ürün yönetimi sayfası
  Widget _buildProductsPage() {
    final myFlowers = ref.watch(storeProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return Stack(
      children: [
        myFlowers.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.local_florist_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('Vitrin boş', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text('Sağ alttaki butona basarak çiçek ekleyin', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: myFlowers.length,
                itemBuilder: (context, index) {
                  final flower = myFlowers[index];
                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: buildResponsiveImage(flower.imagePath, width: 56, height: 56)),
                      title: Text(flower.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(flower.category, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('₺${flower.price.toStringAsFixed(2)}', style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Mevcut', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        Positioned(
          bottom: 16, right: 16,
          child: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (context) => const _AddFlowerForm(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Çiçek Ekle'),
          ),
        ),
      ],
    );
  }
}

// --- Drawer Yardımcıları ---
class _DrawerSection extends StatelessWidget {
  final String title;
  const _DrawerSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5)),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final int index, selected;
  final IconData icon;
  final String label;
  final Color primary;
  final VoidCallback onTap;
  final String? badge;

  const _DrawerItem({required this.index, required this.selected, required this.icon, required this.label, required this.primary, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        color: isSelected ? primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Icon(icon, color: isSelected ? primary : Colors.grey.shade600, size: 22),
        title: Text(label, style: TextStyle(color: isSelected ? primary : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

// --- Mağaza Kurulum Formu (mevcut kod) ---
class _StoreSetupForm extends ConsumerStatefulWidget {
  const _StoreSetupForm();
  @override
  ConsumerState<_StoreSetupForm> createState() => _StoreSetupFormState();
}

class _StoreSetupFormState extends ConsumerState<_StoreSetupForm> {
  final _nameController = TextEditingController();
  final _shippingCostController = TextEditingController();
  String _selectedDeliveryTime = '30-45 dk';
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  String? _logoPath;
  String? _coverPath;

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!);
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) _openTime = picked;
        else _closeTime = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shippingCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Mağaza Profilinizi Oluşturun', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() => _coverPath = 'demo_cover'),
            child: Container(
              height: 120,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300, width: 2)),
              child: _coverPath == null
                  ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.panorama_outlined, size: 32, color: Colors.grey), SizedBox(height: 8), Text('Kapak Fotoğrafı Seç', style: TextStyle(color: Colors.grey))])
                  : const Center(child: Icon(Icons.check_circle, color: Colors.green, size: 40)),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _logoPath = 'demo_logo'),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: primary, width: 2)),
                child: _logoPath == null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.storefront, size: 32, color: primary), const SizedBox(height: 4), const Text('Logo', style: TextStyle(fontSize: 12))])
                    : const Center(child: Icon(Icons.check_circle, color: Colors.green, size: 40)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Mağaza Adı', border: OutlineInputBorder(), fillColor: Colors.white, filled: true)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedDeliveryTime,
            decoration: const InputDecoration(labelText: 'Ortalama Teslimat Süresi', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
            items: ['15-30 dk', '30-45 dk', '45-60 dk', '1-2 Saat'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedDeliveryTime = val!),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _selectTime(context, true),
              style: OutlinedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              icon: const Icon(Icons.wb_sunny_outlined),
              label: Text(_openTime != null ? _openTime!.format(context) : 'Açılış'),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _selectTime(context, false),
              style: OutlinedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              icon: const Icon(Icons.nights_stay_outlined),
              label: Text(_closeTime != null ? _closeTime!.format(context) : 'Kapanış'),
            )),
          ]),
          const SizedBox(height: 16),
          TextField(controller: _shippingCostController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kargo Ücreti (₺) (Ücretsiz ise 0)', border: OutlineInputBorder(), fillColor: Colors.white, filled: true)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              final cost = double.tryParse(_shippingCostController.text);
              if (_nameController.text.trim().isEmpty || _openTime == null || _closeTime == null || cost == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen tüm alanları doldurun'), backgroundColor: Colors.red));
                return;
              }
              final workingHours = '${_openTime!.format(context)} - ${_closeTime!.format(context)}';
              final vendor = Vendor(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _nameController.text.trim(), logoPath: _logoPath ?? '', coverPath: _coverPath ?? '', rating: 0.0, deliveryTime: _selectedDeliveryTime, shippingCost: cost, workingHours: workingHours);
              ref.read(marketplaceProvider.notifier).createStore(name: vendor.name, logoPath: vendor.logoPath, coverPath: vendor.coverPath, deliveryTime: vendor.deliveryTime, shippingCost: vendor.shippingCost, workingHours: vendor.workingHours);
              ref.read(myStoreProfileProvider.notifier).setStore(vendor);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mağazanız başarıyla yayına alındı! 🌸'), backgroundColor: Colors.green));
            },
            child: const Text('Mağazayı Yayına Al', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// --- Çiçek Ekleme Formu (basitleştirilmiş) ---
class _AddFlowerForm extends ConsumerStatefulWidget {
  const _AddFlowerForm();
  @override
  ConsumerState<_AddFlowerForm> createState() => _AddFlowerFormState();
}

class _AddFlowerFormState extends ConsumerState<_AddFlowerForm> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedImagePath;
  String _selectedCategory = 'Buket';

  @override
  void dispose() { _nameController.dispose(); _priceController.dispose(); _descriptionController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding, left: 16, right: 16, top: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Yeni Çiçek Ekle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _selectedImagePath = 'demo_flower_${DateTime.now().millisecondsSinceEpoch}'),
              child: Container(
                height: 120,
                decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2)),
                child: _selectedImagePath == null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 32, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 8), const Text('Görsel Seç')])
                    : const Center(child: Icon(Icons.check_circle, color: Colors.green, size: 40)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Çiçek Adı', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fiyat (₺)', border: OutlineInputBorder()))),
              const SizedBox(width: 16),
              Expanded(child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                items: ['Buket', 'Saksı', 'Aranjman', 'Gelin'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              )),
            ]),
            const SizedBox(height: 16),
            TextField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder(), alignLabelWithHint: true)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final price = double.tryParse(_priceController.text);
                if (_nameController.text.trim().isEmpty || price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad ve fiyat gerekli'), backgroundColor: Colors.red));
                  return;
                }
                ref.read(storeProvider.notifier).addFlower(_nameController.text.trim(), price, _selectedImagePath ?? '', _selectedCategory, description: _descriptionController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Çiçek eklendi! 🌸'), backgroundColor: Colors.green));
              },
              child: const Text('Dükkana Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}