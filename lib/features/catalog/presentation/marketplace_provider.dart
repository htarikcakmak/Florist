import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/vendor.dart';

class MarketplaceNotifier extends Notifier<List<Vendor>> {
  @override
  List<Vendor> build() {
    return []; 
  }

  void createStore({
    required String name, 
    required String logoPath,
    required String coverPath,
    required String deliveryTime,
    required double shippingCost,
    required String workingHours,
  }) {
    final newVendor = Vendor(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      logoPath: logoPath, // Gerçek logo dosyası
      coverPath: coverPath, // Gerçek kapak dosyası
      rating: 0.0,
      deliveryTime: deliveryTime,
      shippingCost: shippingCost,
      workingHours: workingHours,
    );
    
    state = [...state, newVendor];
  }
}

final marketplaceProvider = NotifierProvider<MarketplaceNotifier, List<Vendor>>(() {
  return MarketplaceNotifier();
});