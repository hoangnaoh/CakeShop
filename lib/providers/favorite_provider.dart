import 'package:flutter/material.dart';
import '../models/product.dart';

class FavoriteProvider with ChangeNotifier {
  final List<Product> _favoriteProducts = [];

  List<Product> get favoriteProducts => _favoriteProducts;

  bool isFavorite(String productId) {
    return _favoriteProducts.any((p) => p.id == productId);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product.id)) {
      _favoriteProducts.removeWhere((p) => p.id == product.id);
    } else {
      _favoriteProducts.add(product);
    }
    notifyListeners();
  }
}
