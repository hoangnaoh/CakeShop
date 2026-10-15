import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../customer/notifications_screen.dart';
import '../../widgets/app_brand_logo.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _selectedCategory = 'Tất cả';
  String _selectedStock = 'Tất cả tồn kho'; // Mới thêm filter tồn kho
  int _notificationCount = 2;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await ApiService.getProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  List<String> get _categories {
    final cats = _products.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList();
    cats.insert(0, 'Tất cả');
    return cats;
  }

  String formatCurrency(dynamic amount) {
    if (amount == null) return '0đ';
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(amount);
  }

  Future<void> _deleteProduct(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteProduct(id);
      if (success) {
        _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa sản phẩm')));
        }
      }
    }
  }

  void _showProductForm({Product? product}) {
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toInt().toString() ?? '');
    final stockCtrl = TextEditingController(text: '100'); // Default stock
    final imgCtrl = TextEditingController(text: product?.images.isNotEmpty == true ? product!.images.join(', ') : (product?.imageUrl ?? ''));
    final catCtrl = TextEditingController(text: isEditing ? product.category : '');
    final sizesCtrl = TextEditingController(text: product?.sizes.join(', ') ?? 'Nhỏ, Vừa, Lớn');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF7F9FA),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final previewUrls = imgCtrl.text.split(',').map((u) => u.trim()).where((u) => u.isNotEmpty).toList();
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.9,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F5A3E)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                        AppBrandLogo.horizontal(showAdminBadge: true),
                        const Spacer(),
                        const Icon(Icons.notifications_none, color: Color(0xFF0F5A3E)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(isEditing ? 'Sửa Sản Phẩm' : 'Thêm Sản Phẩm Mới', 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF001A3B))),
                    const SizedBox(height: 8),
                    const Text('Cập nhật thông tin chi tiết cho món bánh của bạn. Những thay đổi này sẽ hiển thị ngay lập tức với khách hàng.', 
                      style: TextStyle(color: Color(0xFF4A5568), fontSize: 13)),
                    const SizedBox(height: 24),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Images Preview Box
                            if (previewUrls.isNotEmpty)
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: previewUrls.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 120,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(16),
                                        image: DecorationImage(
                                          image: NetworkImage(previewUrls[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 40)),
                              ),
                            
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.photo_library_outlined, color: Color(0xFF4A5568)),
                                  const SizedBox(height: 8),
                                  const Text('Kéo thả hoặc nhấn vào đây\nđể tải ảnh lên', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF718096), fontSize: 12)),
                                  TextField(
                                    controller: imgCtrl,
                                    decoration: const InputDecoration(hintText: 'Hoặc nhập các Link Ảnh cách nhau bằng dấu phẩy (,)', border: InputBorder.none, hintStyle: TextStyle(fontSize: 12)),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                    onChanged: (_) => setModalState((){}),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Form Fields
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Tên sản phẩm'),
                                  _buildInput(nameCtrl),
                                  const SizedBox(height: 16),
                                  _buildLabel('Giá bán (VNĐ)'),
                                  _buildInput(priceCtrl, isNumber: true),
                                  const SizedBox(height: 16),
                                  _buildLabel('Kích thước (cách nhau bởi dấu phẩy)'),
                                  _buildInput(sizesCtrl),
                                  const SizedBox(height: 16),
                                  _buildLabel('Danh mục (Nhập mới hoặc chọn bên dưới)'),
                                  _buildInput(catCtrl),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: _categories.where((c) => c != 'Tất cả').map((cat) => ActionChip(
                                      label: Text(cat, style: const TextStyle(fontSize: 11)),
                                      padding: EdgeInsets.zero,
                                      onPressed: () => setModalState(() => catCtrl.text = cat),
                                    )).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildLabel('Mô tả'),
                                  _buildInput(descCtrl),
                                  if (isEditing) ...[
                                    const SizedBox(height: 16),
                                    _buildLabel('Đánh giá của khách hàng'),
                                    Consumer<ReviewProvider>(
                                      builder: (context, reviewProvider, child) {
                                        final productReviews = reviewProvider.getReviewsForProduct(product.id);
                                        if (productReviews.isEmpty) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: Text('Chưa có đánh giá nào cho sản phẩm này.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12)),
                                          );
                                        }
                                        return Column(
                                          children: productReviews.map((r) => Container(
                                            margin: const EdgeInsets.only(top: 8),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(r['user']?['fullName'] ?? 'Khách hàng', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                    Row(children: List.generate(5, (i) => Icon(i < (r['rating'] ?? 5) ? Icons.star : Icons.star_border, size: 14, color: Colors.orange)))
                                                  ]
                                                ),
                                                if (r['comment'] != null && r['comment'].toString().isNotEmpty)
                                                  Padding(padding: const EdgeInsets.only(top: 4), child: Text(r['comment'], style: const TextStyle(fontSize: 12)))
                                              ]
                                            )
                                          )).toList()
                                        );
                                      }
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isSubmitting ? null : () async {
                                  if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                                  setModalState(() => isSubmitting = true);
                                  bool success = false;
                                  
                                  List<String> sizeList = sizesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                                  List<String> imageList = imgCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

                                  if (isEditing) {
                                    success = await ApiService.updateProduct(
                                      id: product.id,
                                      name: nameCtrl.text,
                                      description: descCtrl.text,
                                      category: catCtrl.text,
                                      price: double.tryParse(priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                                      stock: int.tryParse(stockCtrl.text) ?? 100,
                                      images: imageList,
                                      sizes: sizeList,
                                    );
                                  } else {
                                    success = await ApiService.createProduct(
                                      name: nameCtrl.text,
                                      description: descCtrl.text,
                                      category: catCtrl.text,
                                      price: double.tryParse(priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                                      stock: int.tryParse(stockCtrl.text) ?? 100,
                                      images: imageList,
                                      sizes: sizeList,
                                    );
                                  }
                                  
                                  setModalState(() => isSubmitting = false);
                                  if (success) {
                                    Navigator.pop(ctx);
                                    _loadProducts();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra')));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F5A3E), 
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: isSubmitting 
                                    ? const CircularProgressIndicator(color: Colors.white) 
                                    : const Text('Lưu Thay Đổi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4A5568))),
    );
  }

  Widget _buildInput(TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0F5A3E))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: AppBrandLogo.horizontal(showAdminBadge: true),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Color(0xFF0F5A3E)),
                onPressed: () {
                  ApiService.notificationCount.value = 0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen(isAdmin: true)),
                  );
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: ApiService.notificationCount,
                builder: (context, count, child) {
                  if (count > 0) {
                    return Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F5A3E)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text('Quản lý Kho Bánh', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF001A3B))),
                  const SizedBox(height: 8),
                  const Text('Quản lý danh mục sản phẩm và số lượng bánh trong kho.', style: TextStyle(color: Color(0xFF4A5568), fontSize: 14)),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.file_download_outlined, color: Color(0xFF3182CE)),
                          label: const Text('Xuất File', style: TextStyle(color: Color(0xFF3182CE), fontWeight: FontWeight.bold, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade200),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.file_upload_outlined, color: Color(0xFF0F5A3E)),
                          label: const Text('Nhập File', style: TextStyle(color: Color(0xFF0F5A3E), fontWeight: FontWeight.bold, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade200),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showProductForm(),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Thêm Bánh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F5A3E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm bánh ngọt, Mousse, gato...',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                              icon: Icon(Icons.search, color: Colors.grey, size: 20),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedStock,
                              icon: const Icon(Icons.filter_list, size: 16),
                              style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStock = newValue!;
                                });
                              },
                              items: <String>['Tất cả tồn kho', 'Còn hàng', 'Sắp hết', 'Hết hàng']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Categories
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0F5A3E) : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                cat,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF718096),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: _products.isEmpty
                        ? const Center(child: Text('Chưa có sản phẩm nào'))
                          : ListView.builder(
                              itemCount: _products.where((p) {
                                bool catMatch = _selectedCategory == 'Tất cả' || p.category == _selectedCategory;
                                bool stockMatch = true;
                                if (_selectedStock == 'Còn hàng') stockMatch = p.stock > 5;
                                if (_selectedStock == 'Sắp hết') stockMatch = p.stock > 0 && p.stock <= 5;
                                if (_selectedStock == 'Hết hàng') stockMatch = p.stock <= 0;
                                return catMatch && stockMatch;
                              }).length,
                              itemBuilder: (context, index) {
                                final filtered = _products.where((p) {
                                  bool catMatch = _selectedCategory == 'Tất cả' || p.category == _selectedCategory;
                                  bool stockMatch = true;
                                  if (_selectedStock == 'Còn hàng') stockMatch = p.stock > 5;
                                  if (_selectedStock == 'Sắp hết') stockMatch = p.stock > 0 && p.stock <= 5;
                                  if (_selectedStock == 'Hết hàng') stockMatch = p.stock <= 0;
                                  return catMatch && stockMatch;
                                }).toList();
                                final product = filtered[index];
                                
                                // Stock UI
                                Color stockColor = Colors.green;
                                String stockText = 'Còn: ${product.stock} chiếc';
                                if (product.stock <= 0) {
                                  stockColor = Colors.red;
                                  stockText = 'HẾT HÀNG';
                                } else if (product.stock <= 5) {
                                  stockColor = Colors.orange;
                                  stockText = 'Sắp hết: ${product.stock} chiếc';
                                }

                                return GestureDetector(
                                  onTap: () => _showProductForm(product: product),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: 200,
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                                image: DecorationImage(
                                                  image: NetworkImage(product.imageUrl.isNotEmpty ? product.imageUrl : 'https://via.placeholder.com/400'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 16, right: 16,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.9),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(product.category.isNotEmpty ? product.category.toUpperCase() : 'KHÔNG XÁC ĐỊNH', style: const TextStyle(color: Color(0xFF0F5A3E), fontSize: 10, fontWeight: FontWeight.bold)),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () => _showProductForm(product: product),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.9), shape: BoxShape.circle),
                                                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () => _deleteProduct(product.id),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.9), shape: BoxShape.circle),
                                                      child: const Icon(Icons.delete, color: Colors.white, size: 16),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              top: 16, left: 16,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: stockColor,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(stockText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  product.name, 
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text(formatCurrency(product.price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F5A3E))),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
    );
  }
}
