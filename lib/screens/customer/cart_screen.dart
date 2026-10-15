import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'checkout_screen.dart';
import '../../utils/format_utils.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const HomeScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
        ),
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (cart.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Checkbox(
                    value: cart.isAllSelected,
                    activeColor: AppColors.primary,
                    onChanged: (val) => cart.toggleAllSelection(val ?? false),
                  ),
                  const Text('Chọn tất cả', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.neutral)),
                ],
              ),
            ),
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.neutral.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('Giỏ hàng trống', style: TextStyle(fontSize: 18, color: AppColors.neutral.withOpacity(0.5))),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Khám phá sản phẩm ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      final itemKey = cart.items.keys.toList()[i];
                      final price = cartItem.product.getPriceForSize(cartItem.size);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ]
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: cartItem.isSelected,
                              activeColor: AppColors.primary,
                              onChanged: (val) => cart.toggleSelection(itemKey),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: cartItem.product.imageUrl.isNotEmpty
                                  ? Image.network(cartItem.product.imageUrl, width: 80, height: 80, fit: BoxFit.cover)
                                  : Container(width: 80, height: 80, color: Colors.grey[300]),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cartItem.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (cartItem.size.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('Size: ${cartItem.size}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(FormatUtils.formatCurrency(price), style: const TextStyle(color: AppColors.primary)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => cart.updateQuantity(itemKey, cartItem.quantity - 1),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(4)),
                                          child: const Icon(Icons.remove, size: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text('${cartItem.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      GestureDetector(
                                        onTap: () => cart.updateQuantity(itemKey, cartItem.quantity + 1),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(4)),
                                          child: const Icon(Icons.add, size: 16),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => cart.removeItem(itemKey),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (cart.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tạm tính (${cart.selectedItemCount} món):', style: const TextStyle(fontSize: 14, color: AppColors.neutral)),
                      Text(FormatUtils.formatCurrency(cart.selectedTotalAmount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.neutral)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Phí giao hàng:', style: TextStyle(fontSize: 14, color: AppColors.neutral)),
                      Text('Tính ở bước Thanh toán', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.primary)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng thanh toán:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(FormatUtils.formatCurrency(cart.selectedTotalAmount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cart.selectedItems.isEmpty ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text('Tiến hành thanh toán (${cart.selectedItemCount})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            )
        ],
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }
}
