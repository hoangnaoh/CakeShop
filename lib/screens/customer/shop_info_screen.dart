import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import 'map_screen.dart';

class ShopInfoScreen extends StatefulWidget {
  const ShopInfoScreen({super.key});

  @override
  State<ShopInfoScreen> createState() => _ShopInfoScreenState();
}

class _ShopInfoScreenState extends State<ShopInfoScreen> {
  Map<String, dynamic>? _shopInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShopInfo();
  }

  Future<void> _loadShopInfo() async {
    final data = await ApiService.getShopAddress();
    if (mounted) {
      setState(() {
        _shopInfo = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _openMap() async {
    final address = _shopInfo?['address'] ?? '';
    final lat = _shopInfo?['latitude'];
    final lng = _shopInfo?['longitude'];
    
    Uri url;
    if (lat != null && lng != null) {
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else {
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    }
    
    try {
      if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở đường dẫn này')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Chưa cài đặt ứng dụng Bản đồ')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final address = _shopInfo?['address'] ?? 'Chưa cập nhật địa chỉ';
    final lat = _shopInfo?['latitude'] ?? 'N/A';
    final lng = _shopInfo?['longitude'] ?? 'N/A';

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Thông tin cửa hàng', style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Store Info Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.storefront_outlined, color: AppColors.primary, size: 28),
                          SizedBox(width: 12),
                          Text('CakeShop Express', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      const Divider(height: 32),
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Địa chỉ cửa hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.neutral)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(address, style: const TextStyle(color: AppColors.neutral, fontSize: 14, height: 1.5)),
                      const SizedBox(height: 8),
                      Text('📌 Tọa độ: $lat, $lng', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openMap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tertiary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.directions, color: Colors.white),
                          label: const Text('Chỉ đường (Google Maps)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Mini Map Area
                const Text('Bản đồ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.neutral)),
                const SizedBox(height: 12),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                      ),
                      child: const Icon(Icons.location_on, color: Colors.red, size: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // View Detailed Map Button
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen(
                      isSelectionMode: false,
                      initialAddress: address,
                    )));
                  },
                  child: const Text('Xem chi tiết địa chỉ →', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
    );
  }
}
