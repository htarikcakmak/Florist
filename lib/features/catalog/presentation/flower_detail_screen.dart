import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/flower.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../review/presentation/review_provider.dart';
import '../../review/domain/review.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../favorite/presentation/favorite_provider.dart';

Widget _buildResponsiveImage(String path, {double? width, double? height}) {
  return kIsWeb ? Image.network(path, width: width, height: height, fit: BoxFit.cover) : Image.file(File(path), width: width, height: height, fit: BoxFit.cover);
}

class FlowerDetailScreen extends ConsumerStatefulWidget {
  final Flower flower;
  final String vendorName;
  final List<Flower> storeFlowers;

  const FlowerDetailScreen({super.key, required this.flower, required this.vendorName, required this.storeFlowers});

  @override
  ConsumerState<FlowerDetailScreen> createState() => _FlowerDetailScreenState();
}

class _FlowerDetailScreenState extends ConsumerState<FlowerDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animController.forward();
    // Yorumları yükle
    Future.microtask(() => ref.read(reviewProvider.notifier).loadFlowerReviews(int.tryParse(widget.flower.id) ?? 0));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showWriteReviewDialog() {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum yazmak için giriş yapmalısınız.'), backgroundColor: Colors.red),
      );
      return;
    }

    int selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Yorum Yaz', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(ctx).colorScheme.primary)),
              const SizedBox(height: 4),
              Text(widget.flower.name, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 20),

              // Yıldız seçici
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setModalState(() => selectedRating = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      i < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: i < selectedRating ? Colors.amber : Colors.grey.shade400,
                      size: 40,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Düşüncelerinizi paylaşın...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (commentController.text.trim().isEmpty) return;
                  final review = Review(
                    userId: authState.userId ?? 0,
                    userName: authState.name ?? 'Anonim',
                    flowerId: int.tryParse(widget.flower.id) ?? 0,
                    storeId: 0,
                    rating: selectedRating,
                    comment: commentController.text.trim(),
                  );
                  await ref.read(reviewProvider.notifier).submitReview(review, token: authState.token);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Yorumunuz eklendi! 🌸'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                child: const Text('Gönder', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendedFlowers = widget.storeFlowers.where((f) => f.id != widget.flower.id).toList();
    final reviewState = ref.watch(reviewProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          // Büyük kayan resim
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: primary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Favori kalp butonu
              Consumer(builder: (context, ref, _) {
                final favState = ref.watch(favoriteProvider);
                final isFav = favState.favoriteFlowerIds.contains(widget.flower.id);
                return IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        key: ValueKey(isFav),
                        size: 22,
                        color: isFav ? Colors.red : primary,
                      ),
                    ),
                  ),
                  onPressed: () {
                    final authState = ref.read(authProvider);
                    ref.read(favoriteProvider.notifier).toggleFavorite(widget.flower.id, authState.userId ?? 0);
                  },
                );
              }),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(background: _buildResponsiveImage(widget.flower.imagePath, width: double.infinity)),
          ),
          
          // Çiçek Bilgileri
          SliverToBoxAdapter(
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                  .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic)),
              child: FadeTransition(
                opacity: _animController,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.flower.category, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(widget.flower.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text('Ürün Açıklaması', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        widget.flower.description.isEmpty ? 'Satıcı bu ürün için henüz bir açıklama eklememiş.' : widget.flower.description,
                        style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // YORUMLAR BÖLÜMÜ
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Yorumlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          if (reviewState.reviews.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text('${reviewState.reviews.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primary)),
                            ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _showWriteReviewDialog,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Yorum Yaz'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (reviewState.isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  else if (reviewState.reviews.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Text('Henüz yorum yok', style: TextStyle(color: Colors.grey.shade500)),
                            const SizedBox(height: 4),
                            Text('İlk yorumu siz yazın!', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...reviewState.reviews.map((review) => _buildReviewCard(review, primary)),
                ],
              ),
            ),
          ),

          // Önerilen Ürünler
          if (recommendedFlowers.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Bu Mağazanın Diğer Çiçekleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: recommendedFlowers.length,
                        itemBuilder: (context, index) {
                          final recFlower = recommendedFlowers[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FlowerDetailScreen(flower: recFlower, vendorName: widget.vendorName, storeFlowers: widget.storeFlowers)));
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(11)), child: _buildResponsiveImage(recFlower.imagePath, width: double.infinity))),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(recFlower.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text('₺${recFlower.price.toStringAsFixed(2)}', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      
      // Sepete Ekle Barı
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fiyat', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('₺${widget.flower.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    final added = ref.read(cartProvider.notifier).addItem(widget.flower, widget.vendorName);
                    if (added) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [const Icon(Icons.check_circle_outline, color: Colors.white, size: 20), const SizedBox(width: 12), Expanded(child: Text('${widget.flower.name} sepete eklendi!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)))]), backgroundColor: const Color(0xFF34C759), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16), duration: const Duration(seconds: 2)));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Farklı bir mağazadan ürün ekleyemezsiniz.'), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text('Sepete Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review, Color primary) {
    final timeAgo = DateTime.now().difference(review.createdAt);
    String timeText;
    if (timeAgo.inDays > 0) {
      timeText = '${timeAgo.inDays} gün önce';
    } else if (timeAgo.inHours > 0) {
      timeText = '${timeAgo.inHours} saat önce';
    } else {
      timeText = 'Az önce';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i < review.rating ? Colors.amber : Colors.grey.shade300,
                  size: 16,
                )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87)),
        ],
      ),
    );
  }
}