import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    final cartState = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);

    final totalPrice = cartState.items.fold(0.0, (sum, item) => sum + (item.flower.price * item.quantity));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Row(
          children: [
            Text('Sepetim', style: TextStyle(fontWeight: FontWeight.w900, color: primary)),
            if (cartState.items.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('${cartState.items.length}', style: TextStyle(fontSize: 13, color: primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        centerTitle: false,
        actions: [
          if (cartState.items.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Sepet temizlendi'), backgroundColor: primary, behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                );
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Temizle'),
            ),
        ],
      ),
      body: cartState.items.isEmpty
          ? _EmptyCart(primary: primary, cardColor: cardColor)
          : Column(
              children: [
                // Ürün listesi
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return Dismissible(
                        key: ValueKey(item.flower.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) {
                          ref.read(cartProvider.notifier).removeFromCart(item.flower.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item.flower.name} sepetten çıkarıldı'), behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              // Çiçek görsel placeholder
                              Container(
                                width: 70, height: 70,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [primary.withOpacity(0.1), primary.withOpacity(0.05)]),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(Icons.local_florist_rounded, size: 30, color: primary.withOpacity(0.5)),
                              ),
                              const SizedBox(width: 14),
                              // İsim + fiyat
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.flower.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text('₺${item.flower.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, color: primary, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              // Miktar stepper
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _StepperButton(
                                      icon: Icons.remove,
                                      onTap: () {
                                        if (item.quantity > 1) {
                                          ref.read(cartProvider.notifier).updateQuantity(item.flower.id, item.quantity - 1);
                                        } else {
                                          ref.read(cartProvider.notifier).removeFromCart(item.flower.id);
                                        }
                                      },
                                      color: item.quantity == 1 ? Colors.red : primary,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('${item.quantity}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary)),
                                    ),
                                    _StepperButton(
                                      icon: Icons.add,
                                      onTap: () => ref.read(cartProvider.notifier).updateQuantity(item.flower.id, item.quantity + 1),
                                      color: primary,
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
                ),

                // Glassmorphism Checkout Bar
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
                      ),
                      child: Column(
                        children: [
                          // Özet satırları
                          _SummaryRow(label: 'Ara Toplam', value: '₺${totalPrice.toStringAsFixed(2)}'),
                          const SizedBox(height: 6),
                          _SummaryRow(label: 'Kargo', value: totalPrice >= 150 ? 'Ücretsiz' : '₺14.90', highlight: totalPrice >= 150),
                          if (totalPrice < 150) ...[
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: totalPrice / 150,
                              backgroundColor: Colors.grey.shade200,
                              color: primary,
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            const SizedBox(height: 4),
                            Text('₺${(150 - totalPrice).toStringAsFixed(0)} daha ekleyin, kargo bedava!', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          ],
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Toplam', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                                  Text(
                                    '₺${(totalPrice + (totalPrice >= 150 ? 0 : 14.90)).toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primary),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => context.push('/checkout'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Siparişi Tamamla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      SizedBox(width: 6),
                                      Icon(Icons.arrow_forward_rounded, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final Color primary, cardColor;
  const _EmptyCart({required this.primary, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: primary.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(Icons.shopping_bag_outlined, size: 56, color: primary.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text('Sepetin boş', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primary)),
          const SizedBox(height: 8),
          Text('Güzel çiçekler keşfetmeye başla! 🌸', style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.local_florist_rounded),
            label: const Text('Alışverişe Başla', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _StepperButton({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool highlight;
  const _SummaryRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: highlight ? Colors.green : null)),
      ],
    );
  }
}