import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../order/presentation/order_provider.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});
  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(orderProvider.notifier).loadUserOrders(1));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: primary), onPressed: () => context.pop()),
        title: Text('Siparişlerim', style: TextStyle(fontWeight: FontWeight.w900, color: primary)),
        centerTitle: true,
      ),
      body: orderState.orders.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: primary.withOpacity(0.08), shape: BoxShape.circle),
                child: Icon(Icons.receipt_long_rounded, size: 56, color: primary.withOpacity(0.4)),
              ),
              const SizedBox(height: 20),
              Text('Henüz siparişin yok', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 8),
              Text('İlk siparişini vermek için keşfet! 🌸', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              const SizedBox(height: 24),
              ElevatedButton.icon(onPressed: () => context.go('/home'), icon: const Icon(Icons.local_florist_rounded), label: const Text('Alışverişe Başla')),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderState.orders.length,
              itemBuilder: (context, index) {
                final order = orderState.orders[index];
                return _OrderHistoryCard(order: order, cardColor: cardColor, primary: primary);
              },
            ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final Order order;
  final Color cardColor, primary;
  const _OrderHistoryCard({required this.order, required this.cardColor, required this.primary});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final timeAgo = DateTime.now().difference(order.createdAt);
    final timeText = timeAgo.inDays > 0 ? '${timeAgo.inDays} gün önce' : timeAgo.inHours > 0 ? '${timeAgo.inHours} saat önce' : 'Az önce';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(children: [
              Icon(_statusIcon(order.status), color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(order.statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Text('#${order.id}', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
          ),
          // Ürünler
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.local_florist_rounded, color: primary.withOpacity(0.4), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.flowerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('x${item.quantity}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ])),
                  Text('₺${item.price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
                ]),
              )),
              const Divider(),
              Row(children: [
                Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(timeText, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const Spacer(),
                Text('Toplam: ', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                Text('₺${order.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: primary)),
              ]),
              if (order.status == 'DELIVERED') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.star_rounded, size: 18),
                    label: const Text('Yorum Yap', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) => switch (s) { 'PENDING' => Colors.orange, 'PREPARING' => Colors.blue, 'SHIPPED' => Colors.purple, 'DELIVERED' => Colors.green, _ => Colors.grey };
  IconData _statusIcon(String s) => switch (s) { 'PENDING' => Icons.hourglass_bottom_rounded, 'PREPARING' => Icons.restaurant_rounded, 'SHIPPED' => Icons.local_shipping_rounded, 'DELIVERED' => Icons.check_circle_rounded, _ => Icons.help };
}
