import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/presentation/auth_provider.dart';
import '../../catalog/domain/vendor.dart';
import '../../catalog/presentation/marketplace_provider.dart';
import '../../review/presentation/review_provider.dart';
import '../../review/domain/review.dart';
import 'store_provider.dart';

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
  int _selectedTab = 0; // 0 = Ürünlerim, 1 = Yorumlar

  @override
  void initState() {
    super.initState();
    // Yorumları yükle
    Future.microtask(() => ref.read(reviewProvider.notifier).loadStoreReviews(0));
  }

  @override
  Widget build(BuildContext context) {
    final myFlowers = ref.watch(storeProvider);
    final myStoreProfile = ref.watch(myStoreProfileProvider);
    final reviewState = ref.watch(reviewProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(myStoreProfile != null ? myStoreProfile.name : 'Mağaza Kurulumu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: myStoreProfile == null
          ? const _StoreSetupForm()
          : Column(
              children: [
                // Mağaza profil başlığı
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          buildResponsiveImage(myStoreProfile.coverPath, height: 140, width: double.infinity),
                          Positioned(
                            bottom: -30,
                            left: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: getResponsiveImageProvider(myStoreProfile.logoPath),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Çalışma Saatleri:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(myStoreProfile.workingHours, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Teslimat: ${myStoreProfile.deliveryTime}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                Text(
                                  myStoreProfile.shippingCost == 0 ? 'Ücretsiz Kargo' : 'Kargo: ₺${myStoreProfile.shippingCost.toStringAsFixed(2)}',
                                  style: TextStyle(color: myStoreProfile.shippingCost == 0 ? primary : Colors.black87, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Tab seçici: Ürünlerim / Yorumlar
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: _selectedTab == 0 ? primary : Colors.transparent, width: 2.5)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_florist_rounded, size: 18, color: _selectedTab == 0 ? primary : Colors.grey),
                                const SizedBox(width: 6),
                                Text('Ürünlerim (${myFlowers.length})', style: TextStyle(fontWeight: FontWeight.bold, color: _selectedTab == 0 ? primary : Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: _selectedTab == 1 ? primary : Colors.transparent, width: 2.5)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star_rounded, size: 18, color: _selectedTab == 1 ? primary : Colors.grey),
                                const SizedBox(width: 6),
                                Text('Yorumlar (${reviewState.reviews.length})', style: TextStyle(fontWeight: FontWeight.bold, color: _selectedTab == 1 ? primary : Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Tab içeriği
                Expanded(
                  child: _selectedTab == 0
                      ? _buildProductsTab(myFlowers, context)
                      : _buildReviewsTab(reviewState, primary),
                ),
              ],
            ),
      floatingActionButton: myStoreProfile != null
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (context) => const _AddFlowerForm(),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Çiçek Ekle'),
            )
          : null,
    );
  }

  Widget _buildProductsTab(List myFlowers, BuildContext context) {
    if (myFlowers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Mağazanız yayında.\nVitrininiz boş, sağ alttan çiçek eklemeye başlayın.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: myFlowers.length,
      itemBuilder: (context, index) {
        final flower = myFlowers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: buildResponsiveImage(flower.imagePath, width: 50, height: 50),
            ),
            title: Text(flower.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(flower.category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: Text('₺${flower.price.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(ReviewState reviewState, Color primary) {
    if (reviewState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviewState.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Henüz yorum yok', style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Müşterileriniz yorum yaptığında burada görünecek', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    // Ortalama puan
    final avgRating = reviewState.reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviewState.reviews.length;

    return Column(
      children: [
        // Ortalama puan kartı
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(avgRating.toStringAsFixed(1), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primary)),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber, size: 18,
                    )),
                  ),
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
                    final ratio = reviewState.reviews.isNotEmpty ? count / reviewState.reviews.length : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text('$star', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(value: ratio, backgroundColor: Colors.grey.shade200, color: primary, minHeight: 6),
                            ),
                          ),
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

        // Yorum listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reviewState.reviews.length,
            itemBuilder: (context, index) {
              final review = reviewState.reviews[index];
              final timeAgo = DateTime.now().difference(review.createdAt);
              String timeText;
              if (timeAgo.inDays > 0) {
                timeText = '${timeAgo.inDays} gün önce';
              } else if (timeAgo.inHours > 0) {
                timeText = '${timeAgo.inHours} saat önce';
              } else {
                timeText = 'Az önce';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: primary.withOpacity(0.15),
                          child: Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              Text(timeText, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        Row(children: List.generate(5, (i) => Icon(
                          i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: i < review.rating ? Colors.amber : Colors.grey.shade300, size: 16,
                        ))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(review.comment, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

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
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isLogo) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isLogo) _logoPath = image.path;
        else _coverPath = image.path;
      });
    }
  }

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Mağaza Profilinizi Oluşturun', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: _coverPath == null
                  ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.panorama_outlined, size: 32, color: Colors.grey), SizedBox(height: 8), Text('Kapak Fotoğrafı Seç', style: TextStyle(color: Colors.grey))])
                  : ClipRRect(borderRadius: BorderRadius.circular(10), child: buildResponsiveImage(_coverPath!, height: 120, width: double.infinity)),
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => _pickImage(true),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                child: _logoPath == null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.storefront, size: 32, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 4), const Text('Logo', style: TextStyle(fontSize: 12))])
                    : ClipOval(child: buildResponsiveImage(_logoPath!, width: 100, height: 100)),
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

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectTime(context, true),
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  icon: const Icon(Icons.wb_sunny_outlined),
                  label: Text(_openTime != null ? _openTime!.format(context) : 'Açılış'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectTime(context, false),
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                  icon: const Icon(Icons.nights_stay_outlined),
                  label: Text(_closeTime != null ? _closeTime!.format(context) : 'Kapanış'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _shippingCostController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Kargo Ücreti (₺) (Ücretsiz ise 0)', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final cost = double.tryParse(_shippingCostController.text);
              List<String> errors = [];

              if (_coverPath == null) errors.add('Lütfen mağaza kapak fotoğrafını seçin.');
              if (_logoPath == null) errors.add('Lütfen mağazanızın logosunu belirleyin.');
              if (_nameController.text.trim().isEmpty) errors.add('Mağaza adı boş bırakılamaz.');
              if (_openTime == null || _closeTime == null) errors.add('Lütfen açılış ve kapanış saatlerini seçin.');
              if (_shippingCostController.text.trim().isEmpty) {
                errors.add('Kargo ücreti girmelisiniz (Ücretsizse 0 yazın).');
              } else if (cost == null) {
                errors.add('Kargo ücretine geçerli bir rakam girmelisiniz.');
              }

              if (errors.isEmpty) {
                final workingHours = '${_openTime!.format(context)} - ${_closeTime!.format(context)}';
                
                final vendor = Vendor(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text.trim(),
                  logoPath: _logoPath!,
                  coverPath: _coverPath!,
                  rating: 0.0,
                  deliveryTime: _selectedDeliveryTime,
                  shippingCost: cost!,
                  workingHours: workingHours,
                );

                ref.read(marketplaceProvider.notifier).createStore(
                  name: vendor.name, logoPath: vendor.logoPath, coverPath: vendor.coverPath,
                  deliveryTime: vendor.deliveryTime, shippingCost: vendor.shippingCost, workingHours: vendor.workingHours,
                );

                ref.read(myStoreProfileProvider.notifier).setStore(vendor);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mağazanız başarıyla yayına alındı!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: errors.map((errorText) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(errorText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      )).toList(),
                    ),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            child: const Text('Mağazayı Yayına Al', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _AddFlowerForm extends ConsumerStatefulWidget {
  const _AddFlowerForm();
  @override
  ConsumerState<_AddFlowerForm> createState() => _AddFlowerFormState();
}

class _AddFlowerFormState extends ConsumerState<_AddFlowerForm> {
  final _nameController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _nameEsController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionEnController = TextEditingController();
  final _descriptionEsController = TextEditingController();
  
  String? _selectedImagePath;
  String _selectedCategory = 'Buket'; 
  final ImagePicker _picker = ImagePicker();
  
  List<String> _formErrors = [];
  bool _showTranslations = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImagePath = image.path);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnController.dispose();
    _nameEsController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _descriptionEnController.dispose();
    _descriptionEsController.dispose();
    super.dispose();
  }

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
              onTap: _pickImage,
              child: Container(
                height: 120,
                decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2)),
                child: _selectedImagePath == null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 32, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 8), const Text('Görsel Seç')])
                    : ClipRRect(borderRadius: BorderRadius.circular(10), child: buildResponsiveImage(_selectedImagePath!, height: 120, width: double.infinity)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Çiçek Adı', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fiyat (₺)', border: OutlineInputBorder()))),
                const SizedBox(width: 16),
                Expanded(child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                  items: ['Buket', 'Saksı', 'Aranjman', 'Gelin'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                )),
              ],
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Açıklama (Boyut, Bakım, İçerik) - Türkçe', 
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            
            if (_formErrors.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _formErrors.map((errorText) => Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.error_outline, color: Colors.red, size: 18), const SizedBox(width: 8), Expanded(child: Text(errorText, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13)))]))).toList()),
              ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                final price = double.tryParse(_priceController.text);
                List<String> errors = [];
                if (_selectedImagePath == null) errors.add('Lütfen çiçeğin fotoğrafını seçin.');
                if (_nameController.text.trim().isEmpty) errors.add('Lütfen çiçek adını boş bırakmayın.');
                if (_priceController.text.trim().isEmpty) errors.add('Lütfen bir fiyat belirleyin.'); else if (price == null) errors.add('Fiyat geçerli bir rakam olmalı!');

                setState(() => _formErrors = errors);

                if (errors.isEmpty) {
                  ref.read(storeProvider.notifier).addFlower(
                    _nameController.text.trim(), 
                    price!, 
                    _selectedImagePath!, 
                    _selectedCategory, 
                    description: _descriptionController.text.trim(),
                    nameEn: _nameEnController.text.trim().isEmpty ? null : _nameEnController.text.trim(),
                    nameEs: _nameEsController.text.trim().isEmpty ? null : _nameEsController.text.trim(),
                    descriptionEn: _descriptionEnController.text.trim().isEmpty ? null : _descriptionEnController.text.trim(),
                    descriptionEs: _descriptionEsController.text.trim().isEmpty ? null : _descriptionEsController.text.trim(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Çiçek vitrine başarıyla eklendi!'), backgroundColor: Colors.green));
                }
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