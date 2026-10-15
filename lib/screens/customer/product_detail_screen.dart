import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/review_provider.dart';
import 'cart_screen.dart';
import '../../utils/format_utils.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  List<dynamic> reviews = [];
  String avgRating = "0.0";
  String _selectedSize = '';
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    }
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final result = await ApiService.getProductReviews(widget.product.id);
    if (result['success'] == true && mounted) {
      setState(() {
        reviews = result['data'] ?? [];
        avgRating = result['avgRating']?.toString() ?? "0.0";
      });
    }
  }

  double get _currentPrice => widget.product.getPriceForSize(_selectedSize);

  @override
  Widget build(BuildContext context) {
    final imageList = widget.product.images.isNotEmpty ? widget.product.images : (widget.product.imageUrl.isNotEmpty ? [widget.product.imageUrl] : []);
    
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final combinedReviews = [...reviewProvider.getReviewsForProduct(widget.product.id), ...reviews];

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Header
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: imageList.isNotEmpty
                      ? PageView.builder(
                          itemCount: imageList.length,
                          onPageChanged: (index) => setState(() => _currentImageIndex = index),
                          itemBuilder: (context, index) {
                            return Image.network(
                              imageList[index],
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.cake, size: 100, color: Colors.grey),
                        ),
                ),
                if (imageList.length > 1)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        imageList.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImageIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index ? AppColors.primary : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleButton(Icons.arrow_back, () => Navigator.pop(context)),
                        Row(
                          children: [
                            _buildCircleButton(Icons.share_outlined, () {}),
                            const SizedBox(width: 8),
                            Consumer<FavoriteProvider>(
                              builder: (context, favProvider, child) {
                                final isFav = favProvider.isFavorite(widget.product.id);
                                return _buildCircleButton(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  () {
                                    favProvider.toggleFavorite(widget.product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isFav ? 'Đã bỏ yêu thích' : 'Đã thêm vào yêu thích'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  color: isFav ? Colors.red : AppColors.neutral,
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),

            // Details Container
            Container(
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE6D5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            FormatUtils.formatCurrency(_currentPrice),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          avgRating,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.neutral),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${combinedReviews.length} đánh giá)',
                          style: TextStyle(color: AppColors.neutral.withOpacity(0.6), fontSize: 12),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE6D5).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.product.description.isNotEmpty ? widget.product.description : '"Bánh kem tươi cao cấp, lớp kem mịn màng và cốt bánh mềm xốp."',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Row
                    Row(
                      children: [
                        Expanded(child: _buildInfoCard(Icons.timer_outlined, 'Thời gian', '30-45 phút')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildInfoCard(Icons.local_shipping_outlined, 'Giao hàng', 'Tính khi thanh toán')),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Size Selection
                    if (widget.product.sizes.isNotEmpty) ...[
                      Text(
                        'Tùy chọn kích thước',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: widget.product.sizes.map((size) {
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSize = size),
                            child: _buildSizeOption(size, _selectedSize == size),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Preservation Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE6D5).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 20, color: AppColors.neutral),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Bảo quản ngăn mát tủ lạnh (2-5°C) để giữ hương vị tốt nhất.',
                              style: TextStyle(fontSize: 12, color: AppColors.neutral.withOpacity(0.8)),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Reviews Section
                    const Text(
                      'Đánh giá khách hàng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (combinedReviews.isEmpty)
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Khách hàng thân thiết', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Row(
                                      children: List.generate(5, (starIndex) => const Icon(Icons.star, color: Colors.amber, size: 16)),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text('Bánh rất ngon, cốt mềm và kem không bị quá ngọt. Sẽ ủng hộ shop dài dài!', style: TextStyle(color: AppColors.neutral)),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Nguyễn Tuấn', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Row(
                                      children: List.generate(5, (starIndex) => Icon(starIndex < 4 ? Icons.star : Icons.star_border, color: Colors.amber, size: 16)),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text('Giao hàng đúng giờ, bánh trang trí đẹp y hình.', style: TextStyle(color: AppColors.neutral)),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: combinedReviews.length,
                        itemBuilder: (context, index) {
                          final review = combinedReviews[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review['user'] != null ? review['user']['fullName'] : 'Khách hàng',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: List.generate(5, (starIndex) {
                                        return Icon(
                                          starIndex < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(review['comment'] ?? '', style: const TextStyle(color: AppColors.neutral)),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quantity Selector & Price (optional)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Số lượng:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.neutral)),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE6D5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                        child: const Icon(Icons.remove, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => setState(() => quantity++),
                        child: const Icon(Icons.add, color: AppColors.primary, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(widget.product, quantity, _selectedSize);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Đã thêm vào giỏ hàng!'),
                          action: SnackBarAction(
                            label: 'Xem giỏ',
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                            },
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.add_shopping_cart, color: AppColors.primary),
                    label: const Text(
                      'Thêm giỏ hàng',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(widget.product, quantity, _selectedSize);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                    label: const Text(
                      'Mua ngay',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {Color color = AppColors.neutral}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: AppColors.neutral.withOpacity(0.6))),
              Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.neutral)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSizeOption(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFDE6D5) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.neutral,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
