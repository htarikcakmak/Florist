import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../domain/vendor.dart';

class MarketplaceNotifier extends Notifier<List<Vendor>> {
  static const String baseUrl = 'http://10.0.2.2:8080/api/stores';

  @override
  List<Vendor> build() {
    // İlk yüklemede backend'den çek
    _loadFromBackend();
    return [];
  }

  Future<void> _loadFromBackend() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        state = data.map((v) => Vendor.fromJson(v)).toList();
        return;
      }
    } catch (_) {}
    // Backend'e ulaşılamazsa boş liste (yerel ekleme ile dolacak)
  }

  Future<void> refresh() async => _loadFromBackend();

  void createStore({
    required String name,
    required String logoPath,
    required String coverPath,
    required String deliveryTime,
    required double shippingCost,
    required String workingHours,
  }) async {
    final newVendor = Vendor(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      logoPath: logoPath,
      coverPath: coverPath,
      rating: 0.0,
      deliveryTime: deliveryTime,
      shippingCost: shippingCost,
      workingHours: workingHours,
    );

    // Yerel olarak hemen ekle
    state = [...state, newVendor];

    // Backend'e de gönder
    try {
      await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newVendor.toJson()),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }
}

final marketplaceProvider = NotifierProvider<MarketplaceNotifier, List<Vendor>>(() {
  return MarketplaceNotifier();
});