import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReviewProvider with ChangeNotifier {
  // Map of orderId to Review Data
  final Map<String, Map<String, dynamic>> _reviews = {};
  
  // Map of productId to List of Review Data
  final Map<String, List<Map<String, dynamic>>> _productReviews = {};

  bool hasReviewed(String orderId) {
    return _reviews.containsKey(orderId);
  }

  Map<String, dynamic>? getReview(String orderId) {
    return _reviews[orderId];
  }

  Future<bool> checkIfOrderReviewed(String orderId, List<String> productIds) async {
    if (_reviews.containsKey(orderId)) return true;

    for (String productId in productIds) {
      final res = await ApiService.getProductReviews(productId);
      if (res['success'] == true) {
        final list = res['data'] ?? [];
        for (var rev in list) {
          final revOrderId = rev['order'] is Map ? rev['order']['_id'] : rev['order'];
          if (revOrderId == orderId) {
            _reviews[orderId] = {
              'rating': rev['rating'] ?? 5,
              'comment': rev['comment'] ?? '',
              'date': rev['createdAt'] ?? '',
              'user': rev['user'] ?? {'fullName': 'Bạn'}
            };
            notifyListeners();
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<void> addReview(String orderId, List<String> productIds, int rating, String comment) async {
    final reviewData = {
      'rating': rating,
      'comment': comment,
      'date': DateTime.now().toIso8601String(),
      'user': {'fullName': 'Bạn'}
    };

    _reviews[orderId] = reviewData;
    
    for (String productId in productIds) {
      if (!_productReviews.containsKey(productId)) {
        _productReviews[productId] = [];
      }
      // Insert at the beginning so newest reviews are first
      _productReviews[productId]!.insert(0, reviewData);

      // Persist to MongoDB
      await ApiService.addReview(
        orderId: orderId,
        productId: productId,
        rating: rating,
        comment: comment,
      );
    }
    notifyListeners();
  }
  
  List<Map<String, dynamic>> getReviewsForProduct(String productId) {
    return _productReviews[productId] ?? [];
  }
}
