import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../catalog/domain/flower.dart';

class StoreNotifier extends Notifier<List<Flower>> {
  static const String baseUrl = 'http://10.0.2.2:8080/api/flowers';

  @override
  List<Flower> build() {
    return [];
  }

  Future<void> loadFlowersForStore(int storeId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/store/$storeId')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        state = data.map((f) => Flower.fromJson(f)).toList();
        return;
      }
    } catch (_) {}
  }

  void addFlower(String name, double price, String imagePath, String category, {String description = '', String? nameEn, String? nameEs, String? descriptionEn, String? descriptionEs}) async {
    final newFlower = Flower(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      nameEn: nameEn,
      nameEs: nameEs,
      price: price,
      imagePath: imagePath,
      category: category,
      description: description,
      descriptionEn: descriptionEn,
      descriptionEs: descriptionEs,
    );

    // Yerel olarak hemen ekle
    state = [...state, newFlower];

    // Backend'e de gönder
    try {
      await http.post(
        Uri.parse('$baseUrl/store/1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newFlower.toJson()),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }
}

final storeProvider = NotifierProvider<StoreNotifier, List<Flower>>(() {
  return StoreNotifier();
});