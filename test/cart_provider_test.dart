import 'package:flutter_test/flutter_test.dart';
import 'package:CakeShop_app/providers/cart_provider.dart';
import 'package:CakeShop_app/models/product.dart';

void main() {
  group('CartProvider Tests', () {
    late CartProvider cartProvider;

    setUp(() {
      cartProvider = CartProvider();
    });

    test('Initial cart should be empty', () {
      expect(cartProvider.items.isEmpty, true);
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.totalAmount, 0.0);
    });

    test('Adding product should increase item count and total amount', () {
      final product = Product(
        id: 'p1',
        name: 'Bánh Dâu Tây',
        price: 50000,
        imageUrl: '',
        description: '',
      );

      cartProvider.addItem(product, 2, 'Nhỏ');

      expect(cartProvider.itemCount, 1);
      expect(cartProvider.items['p1_Nhỏ']?.quantity, 2);
      expect(cartProvider.totalAmount, 100000.0);
    });

    test('Updating quantity should change total amount', () {
      final product = Product(
        id: 'p1',
        name: 'Bánh Dâu Tây',
        price: 50000,
        imageUrl: '',
        description: '',
      );

      cartProvider.addItem(product, 1, 'Lớn');
      cartProvider.updateQuantity('p1_Lớn', 3);

      expect(cartProvider.items['p1_Lớn']?.quantity, 3);
      expect(cartProvider.totalAmount, 150000.0);
    });

    test('Removing product should clear it from cart', () {
      final product = Product(
        id: 'p1',
        name: 'Bánh Dâu Tây',
        price: 50000,
        imageUrl: '',
        description: '',
      );

      cartProvider.addItem(product, 1, 'Nhỏ');
      cartProvider.removeItem('p1_Nhỏ');

      expect(cartProvider.items.isEmpty, true);
      expect(cartProvider.totalAmount, 0.0);
    });
  });
}
