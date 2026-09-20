import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../review/presentation/review_provider.dart';
import '../../order/presentation/order_provider.dart';

class DashboardHomePage extends ConsumerStatefulWidget {
  const DashboardHomePage({super.key});

  @override
  ConsumerState<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends ConsumerState<DashboardHomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderProvider.notifier).loadStoreOrders(1);
      ref.read(reviewProvider.notifier).loadStoreReviews(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final orderState = ref.watch(orderProvider);
    final reviewState = ref.watch(reviewProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    // Demo istatistikler
    final todayOrders = orderState.orders.where((o) =>
      o.createdAt.day == DateTime.now().day &&
      o.createdAt.month == DateTime.now().month
    ).length;
    final totalRevenue = orderState.orders.fold<double>(0, (sum, o) => sum + o.totalPrice);
    final avgRating = reviewState.reviews.isNotEmpty
        ? reviewState.reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviewState.reviews.length
        : 0.0;
    const visitorCount = 142; // Demo

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hoş geldin kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hoş Geldiniz! 🌸', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Mağazanızın bugünkü performansı',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4 özet kartı
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                icon: Icons.shopping_bag_rounded,
                label: 'Bugünkü Sipariş',
                value: '$todayOrders',
                color: Colors.blue,
                cardColor: cardColor,
              ),
              _StatCard(
                icon: Icons.payments_rounded,
                label: 'Toplam Gelir',
                value: '₺${totalRevenue.toStringAsFixed(0)}',
                color: Colors.green,
                cardColor: cardColor,
              ),
              _StatCard(
                icon: Icons.visibility_rounded,
                label: 'Ziyaretçi',
                value: '$visitorCount',
                color: Colors.orange,
                cardColor: cardColor,
              ),
              _StatCard(
                icon: Icons.star_rounded,
                label: 'Ortalama Puan',
                value: avgRating.toStringAsFixed(1),
                color: Colors.amber,
                cardColor: cardColor,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Son siparişler
          Text('Son Siparişler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary)),
          const SizedBox(height: 12),
          if (orderState.orders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text('Henüz sipariş yok', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )
          else
            ...orderState.orders.take(5).map((order) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_statusIcon(order.status), color: _statusColor(order.status), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sipariş #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(order.statusText, style: TextStyle(fontSize: 12, color: _statusColor(order.status), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Text('₺${order.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 15)),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING': return Colors.orange;
      case 'PREPARING': return Colors.blue;
      case 'SHIPPED': return Colors.purple;
      case 'DELIVERED': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'PENDING': return Icons.hourglass_bottom_rounded;
      case 'PREPARING': return Icons.restaurant_rounded;
      case 'SHIPPED': return Icons.local_shipping_rounded;
      case 'DELIVERED': return Icons.check_circle_rounded;
      default: return Icons.help_outline;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color cardColor;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
