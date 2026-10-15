import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../customer/home_screen.dart';
import 'register_screen.dart';
import '../admin/admin_main_screen.dart';
import '../../widgets/app_brand_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPass = prefs.getString('saved_password');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailCtrl.text = savedEmail;
        _passCtrl.text = savedPass ?? '';
        _rememberMe = true;
      });
    }
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    final success = await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailCtrl.text.trim());
        await prefs.setString('saved_password', _passCtrl.text.trim());
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }

      final profile = await ApiService.getUserProfile();
      setState(() => _isLoading = false);

      if (mounted) {
        final roles = profile?['roles'] as List? ?? ['customer'];
        final isAdmin = roles.contains('admin') || roles.contains('shop') || roles.contains('lender');

        if (isAdmin) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminMainScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thất bại. Kiểm tra lại email/mật khẩu.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Padding(
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
                'Đăng nhập',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chào mừng trở lại CakeShop',
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  Text('Ghi nhớ tôi', style: TextStyle(color: AppColors.neutral.withOpacity(0.7))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Quên mật khẩu?', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('ĐĂNG NHẬP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Chưa có tài khoản? ', style: TextStyle(color: AppColors.neutral.withOpacity(0.7))),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: const Text('Đăng ký ngay', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
