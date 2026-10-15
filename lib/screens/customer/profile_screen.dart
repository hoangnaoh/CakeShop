import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/api_service.dart';
import 'home_screen.dart';
import '../auth/login_screen.dart';
import 'order_history_screen.dart';
import 'shop_info_screen.dart';
import '../admin/admin_edit_profile_screen.dart';
import '../admin/admin_change_password_screen.dart';
import '../admin/admin_help_support_screen.dart';
import '../admin/admin_terms_screen.dart';
import 'favorite_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ApiService.authToken = null;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.secondary,
        appBar: AppBar(
          title: const Text('Tài khoản của tôi', style: TextStyle(color: AppColors.primary)),
          backgroundColor: AppColors.secondary,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        bottomNavigationBar: const BottomNavBar(selectedIndex: 4),
      );
    }

    final String name = _profile?['fullName'] ?? 'Khách hàng';
    final String email = _profile?['email'] ?? 'Chưa cập nhật email';

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Tài khoản của tôi', style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.secondary,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HomeScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header
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
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(color: AppColors.neutral.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on, color: Color(0xFFD97706), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${_profile?['points'] ?? 0} CakeCoins',
                              style: const TextStyle(
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section: Tài khoản của tôi
            _buildSectionTitle('Tài khoản của tôi'),
            _buildListTile(Icons.person_outline, 'Chỉnh sửa hồ sơ', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEditProfileScreen())).then((_) => _loadProfile());
            }),
            _buildListTile(Icons.lock_outline, 'Đổi mật khẩu', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminChangePasswordScreen()));
            }),
            
            const SizedBox(height: 16),

            // Section: Quản lý chung
            _buildSectionTitle('Quản lý chung'),
            _buildListTile(Icons.shopping_bag_outlined, 'Đơn hàng của tôi', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
              );
            }),
            _buildListTile(Icons.location_on_outlined, 'Địa chỉ nhận hàng', () {}),
            _buildListTile(Icons.favorite_border, 'Sản phẩm yêu thích', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteScreen()));
            }),
            
            const SizedBox(height: 16),
            
            // Section: Thông tin & Hỗ trợ
            _buildSectionTitle('Thông tin & Hỗ trợ'),
            _buildListTile(Icons.store_mall_directory_outlined, 'Địa chỉ cửa hàng', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopInfoScreen()),
              );
            }),
            _buildListTile(Icons.help_outline, 'Câu hỏi thường gặp', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHelpSupportScreen()));
            }),
            _buildListTile(Icons.description_outlined, 'Điều khoản sử dụng', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTermsScreen()));
            }),

            const SizedBox(height: 32),

            // Logout
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 4),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.neutral),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}