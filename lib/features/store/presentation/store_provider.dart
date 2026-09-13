import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalog/domain/flower.dart';

class StoreNotifier extends Notifier<List<Flower>> {
  @override
  List<Flower> build() {
    return []; 
  }

  void addFlower(String name, double price, String imagePath, String category, {String description = '', String? nameEn, String? nameEs, String? descriptionEn, String? descriptionEs}) {
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
    state = [...state, newFlower];
  }
}

final storeProvider = NotifierProvider<StoreNotifier, List<Flower>>(() {
  return StoreNotifier();
});