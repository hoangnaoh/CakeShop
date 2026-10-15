import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api_service.dart';

class AdminAddressSettingScreen extends StatefulWidget {
  const AdminAddressSettingScreen({super.key});

  @override
  State<AdminAddressSettingScreen> createState() => _AdminAddressSettingScreenState();
}

class _AdminAddressSettingScreenState extends State<AdminAddressSettingScreen> {
  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController(text: '10.762622');
  final _lngCtrl = TextEditingController(text: '106.660172');
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isGettingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Bước 1: Kiểm tra GPS đã bật chưa
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isGettingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng bật GPS để lấy vị trí')));
        return;
      }

      // Bước 2: Kiểm tra quyền
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isGettingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ứng dụng cần quyền truy cập vị trí')));
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isGettingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng cấp quyền vị trí trong Cài đặt')));
        return;
      }

      // Bước 3: Lấy vị trí (thêm timeout 10s để tránh bị treo trên máy ảo)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Lấy vị trí quá hạn (Timeout). Vui lòng kiểm tra lại GPS hoặc máy ảo.'),
      );

      // Bước 4: Cập nhật UI
      if (mounted) {
        setState(() {
          _latCtrl.text = position.latitude.toString();
          _lngCtrl.text = position.longitude.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật tọa độ thành công!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi lấy vị trí'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadShopAddress();
  }

  Future<void> _loadShopAddress() async {
    final data = await ApiService.getShopAddress();
    if (mounted) {
      setState(() {
        if (data != null) {
          _addressCtrl.text = data['address'] ?? '';
          _latCtrl.text = data['latitude']?.toString() ?? '10.762622';
          _lngCtrl.text = data['longitude']?.toString() ?? '106.660172';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveShopAddress() async {
    if (_addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập địa chỉ'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSaving = true);
    final lat = double.tryParse(_latCtrl.text) ?? 10.762622;
    final lng = double.tryParse(_lngCtrl.text) ?? 106.660172;

    final result = await ApiService.updateShopAddress(_addressCtrl.text, lat, lng);
    setState(() => _isSaving = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật địa chỉ thành công!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Có lỗi xảy ra'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F5A3E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cài đặt Địa chỉ Cửa hàng', style: TextStyle(color: Color(0xFF0F5A3E), fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F5A3E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vị trí cửa hàng', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF001A3B))),
                  const SizedBox(height: 8),
                  const Text('Khách hàng sẽ nhìn thấy địa chỉ này khi họ tiến hành đặt hàng.', style: TextStyle(color: Color(0xFF4A5568))),
                  const SizedBox(height: 24),

                  // Map View Area
                  GestureDetector(
                    onTap: _isGettingLocation ? null : _getCurrentLocation,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isGettingLocation)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              else
                                const Icon(Icons.location_on, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(_isGettingLocation ? 'Đang lấy vị trí...' : 'Lấy vị trí hiện tại', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Địa chỉ chi tiết'),
                        _buildInput(_addressCtrl, 'Số 123 Đường ABC, Quận 1...'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Vĩ độ (Latitude)'),
                                  _buildInput(_latCtrl, '10.762622', isNumber: true),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Kinh độ (Longitude)'),
                                  _buildInput(_lngCtrl, '106.660172', isNumber: true),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveShopAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F5A3E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Cập nhật Địa chỉ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4A5568))),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F5A3E))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
      ),
    );
  }
}
