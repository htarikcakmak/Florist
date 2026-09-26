import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalog/domain/flower.dart';

// Sepetteki ürün yapısı (Ürün ve Adet)
class CartItem {
  final Flower flower;
  int quantity;
  CartItem({required this.flower, this.quantity = 1});
}

// Sepetin Durumu (Hangi mağazadan eklendiği ve içindeki ürünler)
class CartState {
  final String? storeName;
  final List<CartItem> items;
  CartState({this.storeName, this.items = const []});
}

// Sepet Yöneticisi
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState();

  // Ürün ekleme fonksiyonu (Eğer başka mağazaysa FALSE döner)
  bool addItem(Flower flower, String currentStoreName) {
    // 1. KURAL: Sepet doluysa ve mağaza isimleri uyuşmuyorsa reddet!
    if (state.storeName != null && state.storeName != currentStoreName) {
      return false; 
    }

    // Ürün zaten sepette var mı kontrol et
    final existingItemIndex = state.items.indexWhere((item) => item.flower.id == flower.id);
    
    if (existingItemIndex >= 0) {
      // Varsa sadece miktarını artır
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingItemIndex].quantity++;
      state = CartState(storeName: currentStoreName, items: updatedItems);
    } else {
      // Yoksa yeni ürün olarak ekle
      state = CartState(storeName: currentStoreName, items: [...state.items, CartItem(flower: flower)]);
    }
    return true; // Başarıyla eklendi
  }

  // Kullanıcı sepeti sıfırlayıp yeni mağazadan devam etmek isterse çalışır
  void clearCartAndAdd(Flower flower, String newStoreName) {
    state = CartState(storeName: newStoreName, items: [CartItem(flower: flower)]);
  }
  // Sipariş tamamlandığında sepeti tamamen sıfırlar
  void clearCart() {
    state = CartState();
  }

  // Ürünü sepetten çıkar
  void removeFromCart(String flowerId) {
    final updatedItems = state.items.where((item) => item.flower.id != flowerId).toList();
    if (updatedItems.isEmpty) {
      state = CartState();
    } else {
      state = CartState(storeName: state.storeName, items: updatedItems);
    }
  }

  // Ürün miktarını güncelle
  void updateQuantity(String flowerId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(flowerId);
      return;
    }
    final updatedItems = List<CartItem>.from(state.items);
    final index = updatedItems.indexWhere((item) => item.flower.id == flowerId);
    if (index >= 0) {
      updatedItems[index].quantity = newQuantity;
      state = CartState(storeName: state.storeName, items: updatedItems);
    }
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() => CartNotifier());