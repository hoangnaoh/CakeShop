import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../customer/home_screen.dart';
import '../admin/admin_main_screen.dart';
import '../../widgets/app_brand_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  String _selectedRole = 'customer';

  Future<void> _handleRegister() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _phoneCtrl.text.isEmpty || _passCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn phải đồng ý với Điều khoản sử dụng'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await ApiService.register(_emailCtrl.text.trim(), _passCtrl.text.trim(), _nameCtrl.text.trim(), _selectedRole);
    
    if (success) {
      // Lưu sđt sau khi register thành công
      await ApiService.updateProfile(_nameCtrl.text.trim(), _phoneCtrl.text.trim());
      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => _selectedRole == 'admin' ? const AdminMainScreen() : const HomeScreen()), 
          (route) => false
        );
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thất bại. Email có thể đã tồn tại.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Quay lại',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: AppBrandLogo.hero(),
              ),
              const SizedBox(height: 24),
              Text(
                'Tạo tài khoản',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tham gia cùng CakeShop',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.neutral.withOpacity(0.7)),
              ),
              const SizedBox(height: 48),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Họ và tên',
                    icon: Icon(Icons.person_outline, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Email',
                    icon: Icon(Icons.email_outlined, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Số điện thoại',
                    icon: Icon(Icons.phone_outlined, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _passCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Mật khẩu',
                    icon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.neutral.withOpacity(0.5),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _confirmPassCtrl,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Xác nhận lại mật khẩu',
                    icon: const Icon(Icons.lock_reset_outlined, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.neutral.withOpacity(0.5),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text('Tôi đồng ý với Điều khoản sử dụng & Chính sách bảo mật', style: TextStyle(color: AppColors.neutral.withOpacity(0.7), fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('ĐĂNG KÝ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Đã có tài khoản? ', style: TextStyle(color: AppColors.neutral.withOpacity(0.7))),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Đăng nhập', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
