import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../screens/customer/product_detail_screen.dart';
import '../models/product.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart';

import '../utils/format_utils.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.6), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A3921).withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.secondary,
                      child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.cake_outlined, size: 48, color: AppColors.tertiary),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.cake_outlined, size: 48, color: AppColors.tertiary),
                          ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Consumer<FavoriteProvider>(
                      builder: (context, favProvider, child) {
                        final isFav = favProvider.isFavorite(product.id);
                        return GestureDetector(
                          onTap: () {
                            favProvider.toggleFavorite(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isFav ? 'Đã bỏ yêu thích' : 'Đã thêm vào yêu thích ❤️'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isFav ? AppColors.discountTag : AppColors.neutralLight,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 38, // Giữ chiều cao cố định cho đúng 2 dòng, tránh thẻ bị so le
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.category.isNotEmpty)
                            Text(
                              product.category,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.neutralLight,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                            ),
                          const SizedBox(height: 2),
                          Text(
                            FormatUtils.formatCurrency(product.price),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          final cartProvider = Provider.of<CartProvider>(context, listen: false);
                          cartProvider.addItem(product, 1, product.sizes.isNotEmpty ? product.sizes.first : '');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('Đã thêm "${product.name}" vào giỏ')),
                                ],
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
