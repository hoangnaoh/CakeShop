import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_brand_logo.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import 'shop_info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';
  bool _isSearchOpen = false; // Trạng thái ẩn/hiện thanh tìm kiếm khi bấm kính lúp
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final fetched = await ApiService.getProducts();
      if (mounted) {
        setState(() {
          products = fetched;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<String> get _categories {
    final cats = products
        .map((p) => p.category)
        .where((c) => c != null && c.toString().trim().isNotEmpty)
        .map((c) => c.toString().trim())
        .toSet()
        .toList();
    cats.insert(0, 'Tất cả');
    return cats;
  }

  List<Product> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    return products.where((p) {
      final pCat = p.category.trim();
      final matchesCategory = _selectedCategory == 'Tất cả' || pCat == _selectedCategory;
      if (!matchesCategory) return false;
      
      if (query.isEmpty) return true;
      final pName = p.name.toLowerCase();
      final pDesc = p.description.toLowerCase();
      return pName.contains(query) || pDesc.contains(query);
    }).toList();
  }

  // Chuẩn hóa tên danh mục gọn gàng (VD: "Bánh Mousse" -> "Mousse")
  String _formatCategoryLabel(String raw) {
    final trimmed = raw.trim();
    if (trimmed.toLowerCase().startsWith('bánh ')) {
      return trimmed.substring(5).trim();
    }
    return trimmed;
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat == 'tất cả') return Icons.dashboard_outlined;
    if (cat.contains('gato')) return Icons.cake_outlined;
    if (cat.contains('mousse')) return Icons.icecream_outlined;
    if (cat.contains('kem') || cat.contains('cupcake')) return Icons.celebration_outlined;
    if (cat.contains('ngọt') || cat.contains('bánh')) return Icons.bakery_dining_outlined;
    return Icons.cookie_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive cột trên web/máy tính
    final crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.tertiary, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppBrandLogo.drawer(),
                  const SizedBox(height: 8),
                  Text('Tiệm bánh tươi mỗi ngày', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                ],
              ),
            ),
            ..._categories.map((cat) {
              final isSel = _selectedCategory == cat;
              return ListTile(
                leading: Icon(_getCategoryIcon(cat), color: isSel ? AppColors.primary : AppColors.neutralLight),
                title: Text(cat, style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? AppColors.primary : AppColors.neutral)),
                onTap: () {
                  setState(() => _selectedCategory = cat);
                  Navigator.pop(context);
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.neutralLight),
              title: const Text('Về chúng tôi'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CakeShop v1.0 - Tiệm bánh ngọt tươi nướng mỗi ngày')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined, color: AppColors.neutralLight),
              title: const Text('Liên hệ cửa hàng'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopInfoScreen()));
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200), // Tối ưu web không bị tràn
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header chuẩn thiết kế: Menu (trái) - Logo CAKE chính giữa - Kính lúp (phải)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Nút Menu Drawer (Trái)
                        GestureDetector(
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          child: Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            child: const Icon(Icons.menu_rounded, color: AppColors.primary, size: 26),
                          ),
                        ),

                        // Logo CAKE - FRESH & DELICIOUS (Chính giữa)
                        const AppBrandLogo(),

                        // Nút Kính lúp bật/tắt ô tìm kiếm (Phải)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSearchOpen = !_isSearchOpen;
                              if (_isSearchOpen) {
                                Future.delayed(const Duration(milliseconds: 150), () {
                                  _searchFocusNode.requestFocus();
                                });
                              } else {
                                _searchCtrl.clear();
                                _searchQuery = '';
                                _searchFocusNode.unfocus();
                              }
                            });
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _isSearchOpen ? AppColors.primaryLight : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 2. Ô tìm kiếm trượt xuống khi bấm kính lúp (AnimatedSize)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _isSearchOpen
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.border, width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchCtrl,
                                      focusNode: _searchFocusNode,
                                      onChanged: (val) {
                                        setState(() => _searchQuery = val.trim());
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Tìm bánh kem, mousse, tiramisu...',
                                        hintStyle: TextStyle(
                                          color: AppColors.neutralLight.withOpacity(0.8),
                                          fontSize: 13.5,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _searchCtrl.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.neutralLight),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Banner (Chỉ hiện khi không tìm kiếm)
                    if (_searchQuery.isEmpty) ...[
                      Container(
                        height: screenWidth > 600 ? 280 : 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/banner.png'),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5A3921).withOpacity(0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Danh mục bánh
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Danh mục sản phẩm',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.neutral,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.eco_rounded, size: 16, color: AppColors.primary),
                              Container(width: 14, height: 1.5, color: AppColors.primary.withOpacity(0.5)),
                            ],
                          ),
                          if (_selectedCategory != 'Tất cả')
                            GestureDetector(
                              onTap: () => setState(() => _selectedCategory = 'Tất cả'),
                              child: const Text(
                                'Xem tất cả',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            return GestureDetector(
                              onTap: () => setState(() => _selectedCategory = cat),
                              child: _buildCategoryItem(_getCategoryIcon(cat), cat, _selectedCategory == cat),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Tiêu đề danh sách Bánh bán chạy nhất
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              _searchQuery.isNotEmpty 
                                  ? 'Kết quả tìm kiếm cho "$_searchQuery"'
                                  : 'Bánh bán chạy nhất',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.neutral,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.eco_rounded, size: 16, color: AppColors.primary),
                              Container(width: 14, height: 1.5, color: AppColors.primary.withOpacity(0.5)),
                            ],
                          ],
                        ),
                        if (_searchQuery.isEmpty)
                          Row(
                            children: const [
                              Text(
                                'Xem tất cả',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                            ],
                          )
                        else
                          Text(
                            '${_filteredProducts.length} sản phẩm',
                            style: const TextStyle(color: AppColors.neutralLight, fontSize: 13),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    isLoading 
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        )
                      : _filteredProducts.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(40),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Icon(Icons.search_off_rounded, size: 64, color: AppColors.neutralLight.withOpacity(0.5)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Không tìm thấy món bánh phù hợp',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.neutral),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Hãy thử tìm kiếm với từ khóa khác nhé!', style: TextStyle(color: AppColors.neutralLight)),
                                ],
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                return ProductCard(product: _filteredProducts[index]);
                              },
                            ),
                        
                    const SizedBox(height: 100), // Khoảng trống cho bottom nav
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, bool isSelected) {
    final displayLabel = _formatCategoryLabel(label);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                      ? AppColors.primary.withOpacity(0.25) 
                      : Colors.black.withOpacity(0.04),
                  blurRadius: isSelected ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayLabel,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.neutral,
            ),
          ),
        ],
      ),
    );
  }
}
