import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/product_card.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích', style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.secondary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favProvider, child) {
          final favorites = favProvider.favoriteProducts;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: AppColors.neutral.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Bạn chưa yêu thích sản phẩm nào',
                    style: TextStyle(fontSize: 16, color: AppColors.neutral.withOpacity(0.5)),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return ProductCard(product: favorites[index]);
            },
          );
        },
      ),
    );
  }
}
