import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class MapScreen extends StatefulWidget {
  final bool isSelectionMode;
  final String initialAddress;
  final double? lat;
  final double? lng;

  const MapScreen({
    super.key,
    this.isSelectionMode = false,
    this.initialAddress = '',
    this.lat,
    this.lng,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedAddress = "15 Tôn Đức Thắng, Phường Bến Nghé, Quận 1, TP. HCM";

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress.isNotEmpty) {
      _selectedAddress = widget.initialAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isSelectionMode ? 'Chọn vị trí giao hàng' : 'Bản đồ',
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Mock Map Background
          Positioned.fill(
            child: Container(color: Colors.grey[300]),
          ),
          
          // Map Marker Pin
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Text(
                    widget.isSelectionMode ? 'Kéo bản đồ để chọn vị trí' : 'Vị trí hiện tại',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.location_on, color: Colors.red, size: 48),
                const SizedBox(height: 24), // Offset to make the pin point at the center
              ],
            ),
          ),

          // Search Bar Overlay
          if (widget.isSelectionMode)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: _selectedAddress),
                        onChanged: (val) => _selectedAddress = val,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Tìm kiếm địa điểm...',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Action Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Địa chỉ đã chọn:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.isSelectionMode ? _selectedAddress : (widget.initialAddress.isNotEmpty ? widget.initialAddress : 'Vị trí cửa hàng'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (widget.isSelectionMode)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, _selectedAddress);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Xác nhận vị trí', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final address = widget.initialAddress.isNotEmpty ? widget.initialAddress : _selectedAddress;
                          final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
                          try {
                            if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở đường dẫn này')));
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Chưa cài đặt ứng dụng Bản đồ')));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tertiary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        icon: const Icon(Icons.directions, color: Colors.white),
                        label: const Text('Chỉ đường (Mở Google Maps)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
