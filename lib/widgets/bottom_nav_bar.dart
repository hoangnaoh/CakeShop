import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/cart_screen.dart';
import '../screens/customer/notifications_screen.dart';
import '../screens/customer/chat_screen.dart';
import '../screens/customer/profile_screen.dart';
import '../providers/cart_provider.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  
  const BottomNavBar({super.key, this.selectedIndex = 0});

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;
    
    Widget page;
    switch (index) {
      case 0:
        page = const HomeScreen();
        break;
      case 1:
        page = const CartScreen();
        break;
      case 2:
        page = const NotificationsScreen();
        break;
      case 3:
        page = const ChatScreen();
        break;
      case 4:
        page = const ProfileScreen();
        break;
      default:
        page = const HomeScreen();
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5A3921).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildNavItem(context, Icons.home_filled, 'Trang chủ', 0),
                _buildNavItem(context, Icons.shopping_bag_outlined, 'Giỏ hàng', 1),
                _buildNavItem(context, Icons.notifications_none, 'Thông báo', 2),
                _buildNavItem(context, Icons.chat_bubble_outline, 'Chat', 3),
                _buildNavItem(context, Icons.person_outline, 'Tài khoản', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    
    Widget iconWidget = Icon(
      icon,
      color: isSelected ? Colors.white : AppColors.neutral.withOpacity(0.5),
      size: 24,
    );

    if (index == 1) { // Cart
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Consumer<CartProvider>(
            builder: (ctx, cart, child) {
              if (cart.itemCount == 0) return const SizedBox.shrink();
              return Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${cart.itemCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          )
        ],
      );
    }

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: isSelected
                ? BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  )
                : null,
            child: iconWidget,
          ),
          if (isSelected) const SizedBox(height: 4),
          if (isSelected)
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              label,
              style: TextStyle(
                color: AppColors.neutral.withOpacity(0.5),
                fontSize: 12,
              ),
            )
        ],
      ),
    );
  }
}

