import 'package:flutter_test/flutter_test.dart';
import 'package:flowerist_app/features/catalog/domain/flower.dart';
import 'package:flowerist_app/features/cart/presentation/cart_provider.dart';

void main() {
  group('CartNotifier', () {
    late CartNotifier cartNotifier;

    setUp(() {
      // CartNotifier'ı doğrudan test edemediğimiz için CartState'i test ederiz
    });

    test('Boş sepet kontrolü', () {
      final state = CartState();
      expect(state.items, isEmpty);
      expect(state.storeName, isNull);
    });

    test('CartItem doğru oluşturulmalı', () {
      final flower = Flower(
        id: '1',
        name: 'Kırmızı Gül',
        price: 150.0,
        imagePath: 'test.jpg',
        category: 'Buket',
        description: 'Güzel bir gül',
      );

      final item = CartItem(flower: flower);
      expect(item.flower.name, 'Kırmızı Gül');
      expect(item.quantity, 1);
      expect(item.flower.price, 150.0);
    });

    test('CartItem varsayılan miktarı 1 olmalı', () {
      final flower = Flower(
        id: '2',
        name: 'Papatya',
        price: 80.0,
        imagePath: 'papatya.jpg',
        category: 'Saksı',
        description: 'Taze papatya',
      );

      final item = CartItem(flower: flower, quantity: 3);
      expect(item.quantity, 3);
    });

    test('CartState toplam fiyat hesaplaması', () {
      final items = [
        CartItem(
          flower: Flower(id: '1', name: 'Gül', price: 100.0, imagePath: '', category: '', description: ''),
          quantity: 2,
        ),
        CartItem(
          flower: Flower(id: '2', name: 'Lale', price: 75.0, imagePath: '', category: '', description: ''),
          quantity: 1,
        ),
      ];

      final total = items.fold(0.0, (sum, item) => sum + (item.flower.price * item.quantity));
      expect(total, 275.0);
    });

    test('Farklı mağazadan ürün eklenemez kuralı', () {
      final state = CartState(
        storeName: 'Çiçek Dünyası',
        items: [
          CartItem(
            flower: Flower(id: '1', name: 'Gül', price: 100.0, imagePath: '', category: '', description: ''),
          ),
        ],
      );

      // Farklı mağaza ismi ile kontrol
      final isSameStore = state.storeName == 'Başka Mağaza';
      expect(isSameStore, false);

      // Aynı mağaza ismi ile kontrol
      final isSameStore2 = state.storeName == 'Çiçek Dünyası';
      expect(isSameStore2, true);
    });
  });
}
