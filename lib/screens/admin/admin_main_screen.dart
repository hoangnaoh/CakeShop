import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_profile_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return AdminDashboardScreen(
          key: ValueKey(index),
          onTabSelected: (tabIndex) {
            setState(() {
              _selectedIndex = tabIndex;
            });
          },
        );
      case 1:
        return AdminProductsScreen(key: ValueKey(index));
      case 2:
        return AdminOrdersScreen(key: ValueKey(index));
      case 3:
        return AdminProfileScreen(
          key: ValueKey(index),
          onTabSelected: (tabIndex) {
            setState(() {
              _selectedIndex = tabIndex;
            });
          },
        );
      default:
        return AdminDashboardScreen(
          key: ValueKey(index),
          onTabSelected: (tabIndex) {
            setState(() {
              _selectedIndex = tabIndex;
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _selectedIndex == 3
          ? AppBar(
        backgroundColor: const Color(0xFFF7F9FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Tài khoản của tôi',
          style: TextStyle(
            color: Color(0xFF0F5A3E),
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,
      body: _getPage(_selectedIndex),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.dashboard_customize_outlined, 'Tổng quan', 0),
            _buildNavItem(Icons.cake_outlined, 'Kho Bánh', 1),
            _buildNavItem(Icons.receipt_long_outlined, 'Đơn hàng', 2),
            _buildNavItem(Icons.person_outline, 'Tài khoản', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: isSelected
                ? BoxDecoration(
              color: const Color(0xFF0F5A3E),
              borderRadius: BorderRadius.circular(20),
            )
                : null,
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),
          if (isSelected) const SizedBox(height: 4),
          if (isSelected)
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0F5A3E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}