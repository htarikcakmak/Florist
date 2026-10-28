import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class Order {
  final int id;
  final int userId;
  final int storeId;
  final double totalPrice;
  final String status; // PENDING, PREPARING, SHIPPED, DELIVERED
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      storeId: json['storeId'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      items: (json['items'] as List?)?.map((i) => OrderItem.fromJson(i)).toList() ?? [],
    );
  }

  // Durum rengini döndür
  String get statusText {
    switch (status) {
      case 'PENDING': return 'Beklemede';
      case 'PREPARING': return 'Hazırlanıyor';
      case 'SHIPPED': return 'Kargoda';
      case 'DELIVERED': return 'Teslim Edildi';
      case 'CANCELLED': return 'İptal';
      default: return status;
    }
  }
}

class OrderItem {
  final int id;
  final String flowerName;
  final int quantity;
  final double price;

  OrderItem({required this.id, required this.flowerName, required this.quantity, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      flowerName: json['flowerName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class OrderState {
  final List<Order> orders;
  final bool isLoading;

  OrderState({this.orders = const [], this.isLoading = false});
}

class OrderNotifier extends Notifier<OrderState> {
  static const String baseUrl = 'https://flowerist-api.onrender.com/api/orders';

  @override
  OrderState build() => OrderState();

  Future<void> loadUserOrders(int userId) async {
    state = OrderState(orders: state.orders, isLoading: true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/$userId')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        state = OrderState(orders: data.map((o) => Order.fromJson(o)).toList());
        return;
      }
    } catch (_) {}
    state = OrderState(orders: []);
  }

  Future<void> loadStoreOrders(int storeId) async {
    state = OrderState(orders: state.orders, isLoading: true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/store/$storeId')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        state = OrderState(orders: data.map((o) => Order.fromJson(o)).toList());
        return;
      }
    } catch (_) {}
    state = OrderState(orders: []);
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}

    // Yerel olarak güncelle
    state = OrderState(orders: state.orders.map((o) {
      if (o.id == orderId) {
        return Order(id: o.id, userId: o.userId, storeId: o.storeId, totalPrice: o.totalPrice, status: newStatus, createdAt: o.createdAt, items: o.items);
      }
      return o;
    }).toList());
  }
}

final orderProvider = NotifierProvider<OrderNotifier, OrderState>(() => OrderNotifier());
