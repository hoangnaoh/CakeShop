import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/format_utils.dart';
import '../customer/notifications_screen.dart';
import '../customer/order_detail_screen.dart';
import '../../widgets/app_brand_logo.dart';
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<dynamic> _shopOrders = [];
  bool _isLoading = true;
  String _selectedTab = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final shopOrders = await ApiService.getShopOrders();
    if (mounted) {
      setState(() {
        _shopOrders = shopOrders;
        _isLoading = false;
      });
    }
  }

  String formatCurrency(dynamic amount) {
    if (amount == null) return '0đ';
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(amount);
  }

  List<dynamic> get _filteredOrders {
    if (_selectedTab == 'Tất cả') return _shopOrders;
    if (_selectedTab == 'Chờ xử lý') return _shopOrders.where((o) => o['status'] == 'Pending').toList();
    if (_selectedTab == 'Đang thực hiện') return _shopOrders.where((o) => o['status'] == 'Confirmed' || o['status'] == 'Shipping').toList();
    if (_selectedTab == 'Hoàn thành') return _shopOrders.where((o) => o['status'] == 'Delivered' || o['status'] == 'Canceled').toList();
    return _shopOrders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: AppBrandLogo.horizontal(showAdminBadge: true),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Color(0xFF0F5A3E)),
                onPressed: () {
                  ApiService.notificationCount.value = 0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen(isAdmin: true)),
                  );
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: ApiService.notificationCount,
                builder: (context, count, child) {
                  if (count > 0) {
                    return Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F5A3E)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text('Quản lý Đơn hàng', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF001A3B))),
                  const SizedBox(height: 8),
                  const Text('Quản lý luồng đơn hàng hàng ngày của bạn một cách dễ dàng. Hôm nay có vẻ rất bận rộn!', style: TextStyle(color: Color(0xFF4A5568), fontSize: 14)),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(child: _buildStatusCard('${_shopOrders.where((o) => o['status'] == 'Pending').length}', 'Chờ xử lý')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatusCard('${_shopOrders.where((o) => o['status'] == 'Confirmed' || o['status'] == 'Shipping').length}', 'Đang làm')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatusCard('${_shopOrders.where((o) => o['status'] == 'Delivered').length}', 'Hoàn thành')),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Tất cả', 'Chờ xử lý', 'Đang thực hiện', 'Hoàn thành'].map((tab) {
                      final isSelected = _selectedTab == tab;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTab = tab),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected ? const Color(0xFF0F5A3E) : Colors.transparent,
                                width: 2,
                              )
                            )
                          ),
                          child: Text(
                            tab, 
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF0F5A3E) : const Color(0xFF718096),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            )
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm đơn hàng...',
                        hintStyle: TextStyle(color: Colors.grey),
                        icon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: _filteredOrders.isEmpty
                        ? const Center(child: Text('Chưa có đơn hàng nào'))
                        : ListView.builder(
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              final orderId = order['_id']?.toString() ?? '';
                              final formattedId = FormatUtils.formatOrderId(orderId);
                              final totalAmount = order['totalAmount'] ?? 0;
                              final status = order['status'] ?? 'Pending';
                              final fullName = order['shippingAddress']?['fullName'] ?? 'Khách hàng';
                              
                              String itemsStr = 'Bánh ngọt';
                              String imageUrl = '';
                              if (order['items'] != null && order['items'].isNotEmpty) {
                                itemsStr = '${order['items'][0]['quantity']}x ${order['items'][0]['product']?['name'] ?? 'Bánh ngọt'}';
                                final productData = order['items'][0]['product'];
                                if (productData != null) {
                                  if (productData['imageUrl'] != null && productData['imageUrl'].toString().isNotEmpty) {
                                    imageUrl = productData['imageUrl'];
                                  } else if (productData['images'] != null && (productData['images'] as List).isNotEmpty) {
                                    imageUrl = productData['images'][0]['url'] ?? productData['images'][0] ?? '';
                                  }
                                }
                              }

                              String timeStr = 'Dự kiến: ${DateFormat('HH:mm').format(DateTime.now().add(const Duration(hours: 1)))}';
                              if (status == 'Delivered') timeStr = 'Đã giao thành công';
                              else if (status == 'Canceled') timeStr = 'Đã hủy';

                              String btnText = 'Xem chi tiết';
                              if (status == 'Pending') btnText = 'Duyệt đơn';
                              else if (status == 'Confirmed') btnText = 'Giao hàng';

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId))).then((_) => _loadOrders());
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 180,
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                            image: DecorationImage(
                                              image: imageUrl.isNotEmpty ? NetworkImage(imageUrl) as ImageProvider : const AssetImage('assets/images/banner.png'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        if (status == 'Pending')
                                          Positioned(
                                            top: 16, left: 16,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Text('ĐƠN MỚI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('ĐƠN HÀNG $formattedId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4A5568))),
                                              Text(timeStr, style: const TextStyle(color: Color(0xFF0F5A3E), fontSize: 12, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF001A3B))),
                                          const SizedBox(height: 4),
                                          Text(itemsStr, style: const TextStyle(color: Color(0xFF4A5568), fontSize: 14)),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              const Icon(Icons.payments_outlined, color: Color(0xFF0F5A3E), size: 20),
                                              const SizedBox(width: 8),
                                              Text(formatCurrency(totalAmount), style: const TextStyle(color: Color(0xFF0F5A3E), fontWeight: FontWeight.bold)),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: FormatUtils.getStatusBgColor(status),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(FormatUtils.formatStatus(status).toUpperCase(), style: TextStyle(color: FormatUtils.getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold)),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId))).then((_) => _loadOrders());
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF0F5A3E),
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                  ),
                                                  child: Text(btnText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard(String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: label == 'Chờ xử lý' ? const Color(0xFF0F5A3E) : label == 'Đang làm' ? const Color(0xFFB7791F) : const Color(0xFF3182CE))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF4A5568), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
