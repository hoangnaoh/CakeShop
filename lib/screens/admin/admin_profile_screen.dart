import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'admin_bank_setting_screen.dart';
import 'admin_address_setting_screen.dart';
import 'admin_edit_profile_screen.dart';
import 'admin_change_password_screen.dart';
import 'admin_help_support_screen.dart';
import 'admin_terms_screen.dart';
import 'admin_chat_list_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  final Function(int)? onTabSelected;
  const AdminProfileScreen({super.key, this.onTabSelected});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getUserProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              ApiService.authToken = null;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }, 
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final String name = _profile?['fullName'] ?? 'Admin';
    final String email = _profile?['email'] ?? '';

    // Không có Scaffold — AdminMainScreen lo phần đó
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar
          Row(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.neutral)),
                    const SizedBox(height: 4),
                    Text(email, style: TextStyle(color: AppColors.neutral.withOpacity(0.7))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          _buildSectionTitle('Tài khoản của tôi'),
          _buildListTile(Icons.person_outline, 'Chỉnh sửa hồ sơ', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEditProfileScreen())).then((_) => _loadProfile());
          }),
          _buildListTile(Icons.lock_outline, 'Đổi mật khẩu', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChangePasswordScreen()));
          }),

          const SizedBox(height: 24),
          _buildSectionTitle('Quản lý Khách hàng'),
          _buildListTile(Icons.forum_outlined, 'Tin nhắn hỗ trợ (Chat)', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChatListScreen()));
          }),

          const SizedBox(height: 24),
          _buildSectionTitle('Cài đặt Cửa hàng'),
          _buildListTile(Icons.storefront_outlined, 'Địa chỉ Cửa hàng', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAddressSettingScreen()));
          }),
          _buildListTile(Icons.account_balance_wallet_outlined, 'Tài khoản thanh toán', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBankSettingScreen()));
          }),

          const SizedBox(height: 24),
          _buildSectionTitle('Khác'),
          _buildListTile(Icons.help_outline, 'Trợ giúp & Hỗ trợ', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHelpSupportScreen()));
          }),
          _buildListTile(Icons.article_outlined, 'Điều khoản sử dụng', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTermsScreen()));
          }),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('Phiên bản 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.neutral)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}