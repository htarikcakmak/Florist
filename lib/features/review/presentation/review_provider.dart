import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../domain/review.dart';

class ReviewState {
  final List<Review> reviews;
  final bool isLoading;

  ReviewState({this.reviews = const [], this.isLoading = false});
}

class ReviewNotifier extends Notifier<ReviewState> {
  static const String baseUrl = 'https://flowerist-api.onrender.com/api/reviews';

  @override
  ReviewState build() => ReviewState();

  Future<void> loadFlowerReviews(int flowerId) async {
    state = ReviewState(reviews: state.reviews, isLoading: true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/flower/$flowerId')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        state = ReviewState(reviews: data.map((r) => Review.fromJson(r)).toList());
        return;
      }
    } catch (_) {}
    state = ReviewState(reviews: []);
  }

  Future<void> loadStoreReviews(int storeId) async {
    state = ReviewState(reviews: state.reviews, isLoading: true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/store/$storeId')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        state = ReviewState(reviews: data.map((r) => Review.fromJson(r)).toList());
        return;
      }
    } catch (_) {}
    state = ReviewState(reviews: []);
  }

  Future<bool> submitReview(Review review, {String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(review.toJson()),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newReview = Review.fromJson(jsonDecode(response.body));
        state = ReviewState(reviews: [newReview, ...state.reviews]);
        return true;
      }
    } catch (_) {
      // Fallback — yerel olarak ekle
      state = ReviewState(reviews: [review, ...state.reviews]);
      return true;
    }
    return false;
  }
}

final reviewProvider = NotifierProvider<ReviewNotifier, ReviewState>(() => ReviewNotifier());
