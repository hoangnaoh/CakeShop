import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  String size;
  bool isSelected;

  CartItem({required this.product, this.quantity = 1, this.size = '', this.isSelected = true});
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};
  
  Map<String, CartItem> get selectedItems {
    final Map<String, CartItem> selected = {};
    _items.forEach((key, item) {
      if (item.isSelected) selected[key] = item;
    });
    return selected;
  }

  int get itemCount => _items.length;
  
  int get selectedItemCount {
    int count = 0;
    _items.forEach((key, cartItem) {
      if (cartItem.isSelected) count += cartItem.quantity;
    });
    return count;
  }

  bool get isAllSelected => _items.values.every((item) => item.isSelected) && _items.isNotEmpty;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.getPriceForSize(cartItem.size) * cartItem.quantity;
    });
    return total;
  }
  
  double get selectedTotalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      if (cartItem.isSelected) {
        total += cartItem.product.getPriceForSize(cartItem.size) * cartItem.quantity;
      }
    });
    return total;
  }

  void toggleSelection(String key) {
    if (_items.containsKey(key)) {
      _items[key]!.isSelected = !_items[key]!.isSelected;
      notifyListeners();
    }
  }

  void toggleAllSelection(bool isSelected) {
    _items.forEach((key, item) {
      item.isSelected = isSelected;
    });
    notifyListeners();
  }

  void addItem(Product product, int quantity, String size) {
    String key = '${product.id}_$size';
    if (_items.containsKey(key)) {
      _items.update(
        key,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + quantity,
          size: existingItem.size,
          isSelected: existingItem.isSelected,
        ),
      );
    } else {
      _items.putIfAbsent(
        key,
        () => CartItem(product: product, quantity: quantity, size: size, isSelected: true),
      );
    }
    notifyListeners();
  }

  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
  }

  void updateQuantity(String key, int newQuantity) {
    if (!_items.containsKey(key)) return;
    if (newQuantity <= 0) {
      removeItem(key);
    } else {
      _items.update(
        key,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: newQuantity,
          size: existingItem.size,
          isSelected: existingItem.isSelected,
        ),
      );
      notifyListeners();
    }
  }
  
  void removeSelectedItems() {
    _items.removeWhere((key, item) => item.isSelected);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
