import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../order/presentation/order_provider.dart';

class SellerOrdersPage extends ConsumerStatefulWidget {
  const SellerOrdersPage({super.key});

  @override
  ConsumerState<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends ConsumerState<SellerOrdersPage> {
  String _selectedFilter = 'Tümü';
  final filters = ['Tümü', 'PENDING', 'PREPARING', 'SHIPPED', 'DELIVERED'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(orderProvider.notifier).loadStoreOrders(1));
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    final filteredOrders = _selectedFilter == 'Tümü'
        ? orderState.orders
        : orderState.orders.where((o) => o.status == _selectedFilter).toList();

    return Column(
      children: [
        // Filtreler
        Container(
          color: cardColor,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: filters.map((f) {
                final isSelected = _selectedFilter == f;
                final label = _filterLabel(f);
                final count = f == 'Tümü'
                    ? orderState.orders.length
                    : orderState.orders.where((o) => o.status == f).length;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text('$label ($count)'),
                    selectedColor: primary.withOpacity(0.15),
                    checkmarkColor: primary,
                    labelStyle: TextStyle(
                      color: isSelected ? primary : Colors.grey.shade600,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _selectedFilter = f),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Sipariş listesi
        Expanded(
          child: orderState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('Bu kategoride sipariş yok', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _OrderCard(order: order, cardColor: cardColor, primary: primary);
                      },
                    ),
        ),
      ],
    );
  }

  String _filterLabel(String status) {
    switch (status) {
      case 'Tümü': return 'Tümü';
      case 'PENDING': return 'Bekleyen';
      case 'PREPARING': return 'Hazırlanan';
      case 'SHIPPED': return 'Kargoda';
      case 'DELIVERED': return 'Teslim';
      default: return status;
    }
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  final Color cardColor;
  final Color primary;

  const _OrderCard({required this.order, required this.cardColor, required this.primary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(order.status);
    final timeAgo = DateTime.now().difference(order.createdAt);
    String timeText;
    if (timeAgo.inDays > 0) {
      timeText = '${timeAgo.inDays} gün önce';
    } else if (timeAgo.inHours > 0) {
      timeText = '${timeAgo.inHours} saat önce';
    } else if (timeAgo.inMinutes > 0) {
      timeText = '${timeAgo.inMinutes} dk önce';
    } else {
      timeText = 'Az önce';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır: ID + Tarih + Durum
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(order.statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const Spacer(),
              Text('#${order.id}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(width: 8),
              Text(timeText, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ],
          ),
          const SizedBox(height: 12),

          // Ürünler
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.local_florist_rounded, size: 16, color: primary.withOpacity(0.5)),
                const SizedBox(width: 6),
                Expanded(child: Text('${item.flowerName} x${item.quantity}', style: const TextStyle(fontSize: 13))),
                Text('₺${item.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          )),
          const Divider(height: 20),

          // Alt satır: Toplam + Aksiyon butonu
          Row(
            children: [
              Text('Toplam: ', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              Text('₺${order.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary)),
              const Spacer(),
              if (order.status != 'DELIVERED' && order.status != 'CANCELLED')
                ElevatedButton.icon(
                  onPressed: () {
                    final nextStatus = _nextStatus(order.status);
                    if (nextStatus != null) {
                      ref.read(orderProvider.notifier).updateOrderStatus(order.id, nextStatus);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sipariş #${order.id} → ${_statusLabel(nextStatus)}'),
                          backgroundColor: _statusColor(nextStatus),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _statusColor(_nextStatus(order.status) ?? order.status),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(_nextStatusIcon(order.status), size: 16),
                  label: Text(_nextStatusAction(order.status), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
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

  String? _nextStatus(String current) {
    switch (current) {
      case 'PENDING': return 'PREPARING';
      case 'PREPARING': return 'SHIPPED';
      case 'SHIPPED': return 'DELIVERED';
      default: return null;
    }
  }

  String _nextStatusAction(String current) {
    switch (current) {
      case 'PENDING': return 'Hazırla';
      case 'PREPARING': return 'Kargola';
      case 'SHIPPED': return 'Teslim Et';
      default: return '';
    }
  }

  IconData _nextStatusIcon(String current) {
    switch (current) {
      case 'PENDING': return Icons.restaurant_rounded;
      case 'PREPARING': return Icons.local_shipping_rounded;
      case 'SHIPPED': return Icons.check_circle_rounded;
      default: return Icons.help;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING': return 'Beklemede';
      case 'PREPARING': return 'Hazırlanıyor';
      case 'SHIPPED': return 'Kargoda';
      case 'DELIVERED': return 'Teslim Edildi';
      default: return status;
    }
  }
}
