import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'map_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../utils/format_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentMethod = 0; // 0 for EMVCo, 1 for COD
  bool _isLoading = false;
  int _deliveryType = 0; // 0 for Delivery, 1 for Pickup

  final TextEditingController _nameCtrl = TextEditingController(text: 'Nguyễn Văn A');
  final TextEditingController _phoneCtrl = TextEditingController(text: '090 123 4567');
  final TextEditingController _addressCtrl = TextEditingController(text: '123 Đường Lê Lợi, Hải Châu, Đà Nẵng');
  
  double _shippingFee = 15000;
  
  // Khuyến mãi & Tích điểm
  final TextEditingController _voucherCtrl = TextEditingController();
  int _availablePoints = 0;
  bool _usePoints = false;
  double _discountAmount = 0;
  String? _appliedVoucherCode;

  String _shopAddress = 'Đang tải địa chỉ cửa hàng...';
  double _shopLat = 10.762622;
  double _shopLng = 106.660172;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
    _loadUserProfile();
    _loadShopAddress();
    _addressCtrl.addListener(_calculateShippingFee);
    _calculateShippingFee();
  }

  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('last_delivery_address');
    if (savedAddress != null && savedAddress.isNotEmpty) {
      if (mounted) {
        setState(() {
          _addressCtrl.text = savedAddress;
        });
        _calculateShippingFee();
      }
    }
  }

  void _calculateShippingFee() {
    if (_deliveryType == 1) {
      if (_shippingFee != 0.0) setState(() => _shippingFee = 0.0);
      return;
    }
    
    final address = _addressCtrl.text.trim().toLowerCase();
    
    if (address.isEmpty) {
      if (_shippingFee != 0.0) {
        setState(() {
          _shippingFee = 0.0;
        });
      }
      return;
    }
    
    double fee = 15000; // Mặc định trung tâm
    
    if (address.contains('hòa vang')) {
      fee = 50000;
    } else if (address.contains('liên chiểu')) {
      fee = 35000;
    } else if (address.contains('cẩm lệ') || address.contains('ngũ hành sơn')) {
      fee = 25000;
    } else if (address.contains('hải châu') || address.contains('thanh khê') || address.contains('sơn trà')) {
      fee = 15000;
    }

    if (_shippingFee != fee) {
      setState(() {
        _shippingFee = fee;
      });
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _voucherCtrl.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Quyền truy cập vị trí bị từ chối');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Quyền truy cập vị trí bị từ chối vĩnh viễn');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      // Reverse geocoding with OpenStreetMap Nominatim
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1');
      final response = await http.get(url, headers: {'User-Agent': 'CakeShop_App'});
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['display_name'] != null) {
          setState(() {
            _addressCtrl.text = data['display_name'];
          });
          _calculateShippingFee();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật vị trí hiện tại!'), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception('Không thể phân tích địa chỉ');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadShopAddress() async {
    final data = await ApiService.getShopAddress();
    if (mounted && data != null) {
      setState(() {
        _shopAddress = data['address'] ?? 'Shop CakeShop';
        _shopLat = double.tryParse(data['latitude']?.toString() ?? '') ?? 10.762622;
        _shopLng = double.tryParse(data['longitude']?.toString() ?? '') ?? 106.660172;
      });
    } else if (mounted) {
      setState(() {
        _shopAddress = 'Shop CakeShop - 123 Đường Bánh Ngọt';
      });
    }
  }

  Future<void> _loadUserProfile() async {
    final profile = await ApiService.getUserProfile();
    if (profile != null) {
      setState(() {
        _availablePoints = profile['points'] ?? 0;
        if (profile['fullName'] != null && profile['fullName'].toString().isNotEmpty) {
          _nameCtrl.text = profile['fullName'];
        }
        if (profile['phone'] != null && profile['phone'].toString().isNotEmpty) {
          _phoneCtrl.text = profile['phone'];
        }
      });
    }
  }

  Future<void> _applyVoucher() async {
    if (_voucherCtrl.text.isEmpty) return;
    
    final cart = Provider.of<CartProvider>(context, listen: false);
    final result = await ApiService.validateVoucher(
      _voucherCtrl.text.trim(), 
      cart.selectedTotalAmount
    );

    if (result['success'] == true) {
      setState(() {
        _discountAmount = (result['data']['discountPreview'] ?? 0).toDouble();
        _appliedVoucherCode = _voucherCtrl.text.trim().toUpperCase();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Áp dụng mã thành công!'), backgroundColor: Colors.green),
      );
    } else {
      setState(() {
        _discountAmount = 0;
        _appliedVoucherCode = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Mã không hợp lệ'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitOrder() async {
    setState(() => _isLoading = true);

    final cart = Provider.of<CartProvider>(context, listen: false);
    final items = cart.selectedItems.values.map((item) => {
      'productId': item.product.id,
      'quantity': item.quantity,
      'size': item.size,
    }).toList();

    // Save address for next time if delivery
    if (_deliveryType == 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_delivery_address', _addressCtrl.text.trim());
    }

    // Call API
    final result = await ApiService.createOrder(
      items: items,
      paymentMethod: _selectedPaymentMethod == 0 ? 'EMVCo' : 'COD',
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      address: _deliveryType == 0 ? _addressCtrl.text : 'Nhận bánh tại cửa hàng',
      shippingFee: _shippingFee,
      voucherCode: _appliedVoucherCode,
      usePoints: _usePoints ? _availablePoints : 0,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Thành công, có thể hiển thị mã QR nếu là EMVCo
      final orderData = result['data'];
      if (_selectedPaymentMethod == 0 && orderData['qrCodeUrl'] != null) {
        _showQrCodeDialog(orderData['qrCodeUrl'], orderData['_id']);
      } else {
        cart.removeSelectedItems(); // Clear chỉ những món đã chọn mua
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thành công!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else {
      // Lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Lỗi đặt hàng')),
      );
    }
  }

  void _showQrCodeDialog(String qrCodeData, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentQrDialog(qrCodeData: qrCodeData, orderId: orderId),
    );
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CakeShop',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
              ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Address Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.storefront_outlined, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cửa hàng xử lý đơn (Giao hàng từ đây)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.neutral)),
                        const SizedBox(height: 4),
                        Text(_shopAddress, style: TextStyle(color: AppColors.neutral.withOpacity(0.7), fontSize: 13)),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MapScreen(
                                  isSelectionMode: false,
                                  initialAddress: _shopAddress,
                                  lat: _shopLat,
                                  lng: _shopLng,
                                ),
                              ),
                            );
                          },
                          child: const Text('Xem trên bản đồ', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tổng tiền preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE6D5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tạm tính (${cart.selectedItemCount} sản phẩm)', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(FormatUtils.formatCurrency(cart.selectedTotalAmount), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Phí vận chuyển', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(FormatUtils.formatCurrency(_shippingFee), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      Text(FormatUtils.formatCurrency(cart.selectedTotalAmount + _shippingFee), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, color: AppColors.neutral),
                      const SizedBox(width: 12),
                      Text(
                        'Thông tin giao hàng',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _deliveryType = 0);
                              _calculateShippingFee();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _deliveryType == 0 ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text('Giao hàng tận nơi', style: TextStyle(fontWeight: FontWeight.bold, color: _deliveryType == 0 ? Colors.white : Colors.grey[600])),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _deliveryType = 1);
                              _calculateShippingFee();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _deliveryType == 1 ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text('Nhận tại cửa hàng', style: TextStyle(fontWeight: FontWeight.bold, color: _deliveryType == 1 ? Colors.white : Colors.grey[600])),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('Họ và tên', 'Ví dụ: Nguyễn Văn A', _nameCtrl),
                  const SizedBox(height: 16),
                  _buildTextField('Số điện thoại', 'Ví dụ: 090 123 4567', _phoneCtrl),
                  const SizedBox(height: 16),
                  _buildTextField('Thời gian nhận', 'Ví dụ: Giao ngay, hoặc 15:00 ngày mai', null),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Ghi chú cho đơn hàng',
                    'Ví dụ: Ghi chữ "Chúc mừng sinh nhật", giao trước 5h chiều...',
                    null, // we can just use a dummy null for now, or create a controller
                    maxLines: 2,
                  ),
                  if (_deliveryType == 0) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Địa chỉ nhận hàng',
                      'Nhập địa chỉ...',
                      _addressCtrl,
                      isLocation: true,
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Promo & Points
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.loyalty_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text('Khuyến mãi & Tích điểm', style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('Mã giảm giá', 'Nhập mã...', _voucherCtrl),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: ElevatedButton(
                          onPressed: _applyVoucher,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text('Áp dụng', style: TextStyle(color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                  if (_discountAmount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Đã giảm ${FormatUtils.formatCurrency(_discountAmount)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text('Sử dụng $_availablePoints CakeCoins\n(Tương đương giảm ${FormatUtils.formatCurrency(_availablePoints.toDouble())})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Switch(
                        value: _usePoints,
                        activeColor: AppColors.primary,
                        onChanged: _availablePoints > 0 ? (val) {
                          setState(() { _usePoints = val; });
                        } : null,
                      )
                    ],
                  ),
                  if (_usePoints)
                    Text('Giảm thêm ${FormatUtils.formatCurrency(_availablePoints.toDouble())}', style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Phương thức thanh toán',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildPaymentOption(
                    index: 0,
                    title: 'Chuyển khoản Ngân hàng',
                    subtitle: 'Tự động xác nhận ngay lập tức qua mọi App Ngân hàng & ví điện tử',
                    icon: Icons.qr_code_scanner_rounded,
                    tag: 'Khuyên dùng',
                  ),
                  const SizedBox(height: 14),
                  _buildPaymentOption(
                    index: 1,
                    title: 'Thanh toán tiền mặt khi nhận hàng',
                    subtitle: 'Kiểm tra bánh và thanh toán trực tiếp cho shipper',
                    icon: Icons.payments_rounded,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            // Billing summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tạm tính:', style: TextStyle(color: AppColors.neutral)),
                      Text(FormatUtils.formatCurrency(cart.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_deliveryType == 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Phí giao hàng:', style: TextStyle(color: AppColors.neutral)),
                        Text(
                          _shippingFee == 0 ? 'Miễn phí' : FormatUtils.formatCurrency(_shippingFee),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.neutral),
                        ),
                      ],
                    ),
                  ],
                  if (_discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Giảm giá:', style: TextStyle(color: AppColors.neutral)),
                        Text('-${FormatUtils.formatCurrency(_discountAmount)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  if (_usePoints) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Điểm CakeCoins:', style: TextStyle(color: AppColors.neutral)),
                        Text('-${FormatUtils.formatCurrency(_availablePoints.toDouble())}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng thanh toán:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        FormatUtils.formatCurrency((cart.selectedTotalAmount + _shippingFee - _discountAmount - (_usePoints ? _availablePoints : 0)).clamp(0, double.infinity)),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.tertiary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Xác nhận đặt hàng',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController? controller, {bool isLocation = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB), // Secondary
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(color: AppColors.neutral, fontSize: 14),
                  ),
                ),
              ),
              if (isLocation)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final selectedAddress = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapScreen(
                              isSelectionMode: true,
                              initialAddress: controller?.text ?? '',
                            ),
                          ),
                        );
                        if (selectedAddress != null && controller != null) {
                          setState(() {
                            controller.text = selectedAddress;
                          });
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
                        child: Icon(Icons.map_outlined, color: AppColors.primary, size: 24),
                      ),
                    ),
                    GestureDetector(
                      onTap: _getCurrentLocation,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 12.0, right: 8.0),
                        child: Icon(Icons.gps_fixed, color: Colors.blue, size: 24),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    String? tag,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 6.5 : 2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isSelected ? AppColors.primaryDark : AppColors.neutral,
                          ),
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralLight,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.neutralLight,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentQrDialog extends StatefulWidget {
  final String qrCodeData;
  final String orderId;

  const PaymentQrDialog({
    super.key,
    required this.qrCodeData,
    required this.orderId,
  });

  @override
  State<PaymentQrDialog> createState() => _PaymentQrDialogState();
}

class _PaymentQrDialogState extends State<PaymentQrDialog> {
  late Timer _countdownTimer;
  late Timer _pollingTimer;
  int _secondsLeft = 900; // 15 minutes
  String _statusText = 'Đang chờ thanh toán...';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _startPolling();
    // Check status immediately on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPaymentStatus();
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timerCancel();
        setState(() {
          _statusText = 'Đã hết thời gian thanh toán!';
        });
      }
    });
  }

  void _startPolling() {
    // Poll every 30 seconds as requested
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    // Pass forceSync = true on periodic checks to trigger casso sync
    final order = await ApiService.getOrderById(widget.orderId, forceSync: true);
    if (order != null && order['paymentStatus'] == 'Paid') {
      _timerCancel();
      if (mounted) {
        setState(() {
          _isSuccess = true;
          _statusText = 'Thanh toán thành công!';
        });
      }
      
      // Wait a bit to show success message, then close
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Clear selected items in cart
          Provider.of<CartProvider>(context, listen: false).removeSelectedItems();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đặt hàng và thanh toán thành công!'), backgroundColor: Colors.green),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      });
    }
  }

  void _timerCancel() {
    _countdownTimer.cancel();
    _pollingTimer.cancel();
  }

  @override
  void dispose() {
    _timerCancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.qr_code_scanner, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Thanh toán đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _statusText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isSuccess ? Colors.green : (_secondsLeft == 0 ? Colors.red : AppColors.primary),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (_secondsLeft > 0 && !_isSuccess) ...[
            Text(
              'Thời gian thanh toán còn lại: ${_formatTime(_secondsLeft)}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: SizedBox(
                width: 200,
                height: 200,
                child: QrImageView(
                  data: widget.qrCodeData,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ] else if (_isSuccess) ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
          ] else ...[
            const Icon(Icons.error_outline, color: Colors.red, size: 80),
            const SizedBox(height: 16),
          ],
        ],
      ),
      actions: [
        if (!_isSuccess)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Đóng', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }
}
