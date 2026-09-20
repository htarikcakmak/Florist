import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class FavoriteState {
  final Set<String> favoriteFlowerIds;
  final bool isLoading;

  FavoriteState({this.favoriteFlowerIds = const {}, this.isLoading = false});
}

class FavoriteNotifier extends Notifier<FavoriteState> {
  static const String baseUrl = 'http://10.0.2.2:8080/api/favorites';

  @override
  FavoriteState build() => FavoriteState();

  Future<void> loadFavorites(int userId) async {
    state = FavoriteState(favoriteFlowerIds: state.favoriteFlowerIds, isLoading: true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/$userId')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final ids = data.map((f) => f['flowerId'].toString()).toSet();
        state = FavoriteState(favoriteFlowerIds: ids);
        return;
      }
    } catch (_) {}
    state = FavoriteState(favoriteFlowerIds: state.favoriteFlowerIds);
  }

  bool isFavorite(String flowerId) => state.favoriteFlowerIds.contains(flowerId);

  Future<void> toggleFavorite(String flowerId, int userId) async {
    final currentIds = Set<String>.from(state.favoriteFlowerIds);

    if (currentIds.contains(flowerId)) {
      // Favoriden çıkar
      currentIds.remove(flowerId);
      state = FavoriteState(favoriteFlowerIds: currentIds);
      try {
        await http.delete(Uri.parse('$baseUrl/$userId/${int.tryParse(flowerId) ?? 0}')).timeout(const Duration(seconds: 5));
      } catch (_) {}
    } else {
      // Favoriye ekle
      currentIds.add(flowerId);
      state = FavoriteState(favoriteFlowerIds: currentIds);
      try {
        await http.post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'flowerId': int.tryParse(flowerId) ?? 0}),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
  }
}

final favoriteProvider = NotifierProvider<FavoriteNotifier, FavoriteState>(() => FavoriteNotifier());
