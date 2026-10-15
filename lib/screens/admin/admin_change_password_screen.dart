import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class AdminChangePasswordScreen extends StatefulWidget {
  const AdminChangePasswordScreen({super.key});

  @override
  State<AdminChangePasswordScreen> createState() => _AdminChangePasswordScreenState();
}

class _AdminChangePasswordScreenState extends State<AdminChangePasswordScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isSaving = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _changePassword() async {
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu xác nhận không khớp!')));
      return;
    }
    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin!')));
      return;
    }

    setState(() => _isSaving = true);
    final success = await ApiService.updatePassword(_oldPassCtrl.text.trim(), _newPassCtrl.text.trim());
    setState(() => _isSaving = false);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu hiện tại không đúng hoặc có lỗi xảy ra!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        title: const Text('Đổi mật khẩu', style: TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neutral),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Vui lòng nhập mật khẩu cũ và mật khẩu mới để tăng cường bảo mật cho tài khoản của bạn.', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 32),
            _buildPasswordField('Mật khẩu hiện tại', _oldPassCtrl, _obscureOld, () => setState(() => _obscureOld = !_obscureOld)),
            const SizedBox(height: 16),
            _buildPasswordField('Mật khẩu mới', _newPassCtrl, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
            const SizedBox(height: 16),
            _buildPasswordField('Xác nhận mật khẩu mới', _confirmPassCtrl, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSaving ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Cập nhật mật khẩu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscureText, VoidCallback onToggle) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
