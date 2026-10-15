import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import 'order_detail_screen.dart';

import '../../utils/format_utils.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await ApiService.getMyOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  String _selectedFilter = 'Tất cả';
  final List<String> _filters = ['Tất cả', 'Chờ duyệt', 'Đang giao', 'Hoàn thành', 'Đã hủy'];

  String _mapStatusToFilter(String apiStatus) {
    switch (apiStatus) {
      case 'Pending': return 'Chờ duyệt';
      case 'Shipping': return 'Đang giao';
      case 'Delivered': return 'Hoàn thành';
      case 'Canceled': return 'Đã hủy';
      default: return 'Tất cả';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders.where((order) {
      if (_selectedFilter == 'Tất cả') return true;
      return _mapStatusToFilter(order['status'] ?? '') == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi', style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.secondary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.neutral,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : filteredOrders.isEmpty
                    ? const Center(child: Text('Không có đơn hàng nào'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                    final orderId = order['_id'] ?? '';
                    final totalAmount = FormatUtils.formatCurrency(order['totalAmount']);
                    final status = FormatUtils.formatStatus(order['status'] ?? 'pending');

                    String itemsStr = 'Sản phẩm';
                    if (order['items'] != null && order['items'].isNotEmpty) {
                      itemsStr = '${order['items'][0]['quantity']}x ${order['items'][0]['product']?['name'] ?? 'Bánh ngọt'}';
                      if (order['items'].length > 1) {
                        itemsStr += ' và ${order['items'].length - 1} món khác';
                      }
                    }

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      color: AppColors.surface,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.receipt_long, color: AppColors.primary),
                        ),
                        title: Row(
                          children: [
                            const Text('Mã đơn: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(FormatUtils.formatOrderId(orderId.toString()), style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1.2, color: AppColors.primary, fontSize: 14)),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(itemsStr, style: TextStyle(color: AppColors.neutral.withOpacity(0.7))),
                            const SizedBox(height: 4),
                            Text('Tổng: $totalAmount - Trạng thái: $status'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
                          );
                        },
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
