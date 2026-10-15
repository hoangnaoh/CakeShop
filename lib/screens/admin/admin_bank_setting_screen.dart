import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class AdminBankSettingScreen extends StatefulWidget {
  const AdminBankSettingScreen({super.key});

  @override
  State<AdminBankSettingScreen> createState() => _AdminBankSettingScreenState();
}

class _AdminBankSettingScreenState extends State<AdminBankSettingScreen> {
  final TextEditingController _binCtrl = TextEditingController();
  final TextEditingController _accNumCtrl = TextEditingController();
  final TextEditingController _accNameCtrl = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentBankInfo();
  }

  Future<void> _loadCurrentBankInfo() async {
    final info = await ApiService.getAdminBankInfo();
    if (info != null) {
      setState(() {
        _binCtrl.text = info['bin'] ?? '';
        _accNumCtrl.text = info['accountNumber'] ?? '';
        _accNameCtrl.text = info['accountName'] ?? '';
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_binCtrl.text.isEmpty || _accNumCtrl.text.isEmpty || _accNameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Lưu ý: Cần chắc chắn ApiService.authToken hiện tại là của một user có role "admin"
    final result = await ApiService.updateAdminBankInfo(
      _binCtrl.text.trim(),
      _accNumCtrl.text.trim(),
      _accNameCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật tài khoản thanh toán thành công!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Lỗi cập nhật'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thiết lập Thanh toán',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(24),
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
              const Icon(Icons.account_balance, size: 40, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Tài khoản nhận tiền',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Mã QR thanh toán tự động (EMVCo) sẽ được tạo dựa trên cấu hình này.',
                style: TextStyle(color: AppColors.neutral.withOpacity(0.7), fontSize: 13),
              ),
              const SizedBox(height: 24),

              _buildInputLabel('Chọn Ngân hàng'),
              _buildBankDropdown(),
              
              const SizedBox(height: 20),
              _buildInputLabel('Số tài khoản'),
              _buildTextField(_accNumCtrl, 'Nhập số tài khoản ngân hàng'),
              
              const SizedBox(height: 20),
              _buildInputLabel('Tên chủ tài khoản'),
              _buildTextField(_accNameCtrl, 'VD: NGUYEN VAN A', textCapitalization: TextCapitalization.characters),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'LƯU CẤU HÌNH',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.neutral),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextCapitalization textCapitalization = TextCapitalization.none}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.neutral.withOpacity(0.4), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBankDropdown() {
    final Map<String, String> banks = {
      '970436': 'Vietcombank',
      '970415': 'VietinBank',
      '970418': 'BIDV',
      '970405': 'Agribank',
      '970407': 'Techcombank',
      '970422': 'MBBank',
      '970416': 'ACB',
      '970432': 'VPBank',
      '970423': 'TPBank',
      '970403': 'Sacombank',
    };

    // Make sure the current _binCtrl.text is in the list, otherwise default to first
    String currentValue = banks.containsKey(_binCtrl.text) ? _binCtrl.text : '970436';
    if (_binCtrl.text.isEmpty) _binCtrl.text = currentValue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          items: banks.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _binCtrl.text = newValue;
              });
            }
          },
        ),
      ),
    );
  }
}
