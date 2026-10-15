import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/format_utils.dart';
import '../customer/notifications_screen.dart';
import '../customer/order_detail_screen.dart';
import '../../widgets/app_brand_logo.dart';
class AdminDashboardScreen extends StatefulWidget {
  final Function(int)? onTabSelected;
  const AdminDashboardScreen({super.key, this.onTabSelected});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _revenue;
  List<dynamic> _shopOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final revenue = await ApiService.getShopRevenue();
    final shopOrders = await ApiService.getShopOrders();
    
    if (mounted) {
      setState(() {
        _revenue = revenue;
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
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Xin chào, Quản lý', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF001A3B))),
                  const SizedBox(height: 8),
                  const Text('Hôm nay là một ngày bận rộn. Đây là trạng thái cửa hàng của bạn.', style: TextStyle(color: Color(0xFF4A5568), fontSize: 14)),
                  const SizedBox(height: 24),

                  // Revenue Card
                  _buildStatCard(
                    title: 'DOANH THU TỔNG',
                    value: formatCurrency(_revenue?['totalRevenue']),
                    subtitle: 'Cập nhật lúc ${DateFormat('HH:mm').format(DateTime.now())}',
                    subtitleColor: const Color(0xFF0F5A3E),
                    icon: Icons.payments_outlined,
                    iconBgColor: const Color(0xFFE6F4EA),
                    iconColor: const Color(0xFF0F5A3E),
                  ),

                  // Total Orders Card
                  _buildStatCard(
                    title: 'TỔNG ĐƠN HÀNG',
                    value: '${_revenue?['totalOrders'] ?? 0}',
                    subtitle: 'Tính đến hôm nay',
                    subtitleColor: const Color(0xFF718096),
                    icon: Icons.shopping_bag_outlined,
                    iconBgColor: const Color(0xFFEBF8FF),
                    iconColor: const Color(0xFF3182CE),
                  ),

                  // Low Stock Card
                  _buildStatCard(
                    title: 'TÌNH TRẠNG KHO BÁNH',
                    value: '0', // Assume 0 out of stock for now
                    subtitle: 'Tất cả sản phẩm còn hàng',
                    subtitleColor: const Color(0xFF059669),
                    subtitleUnderline: false,
                    icon: Icons.check_circle_outline,
                    iconBgColor: const Color(0xFFD1FAE5),
                    iconColor: const Color(0xFF059669),
                    bgColor: const Color(0xFFF0FDF4),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Đơn hàng gần đây', style: TextStyle(fontSize: 16, color: Color(0xFF4A5568), fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => widget.onTabSelected?.call(2), 
                        child: const Text('Xem tất cả →', style: TextStyle(color: Color(0xFF0F5A3E), fontWeight: FontWeight.w600))
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_shopOrders.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Chưa có đơn hàng nào.')))
                  else
                    ..._shopOrders.take(3).map((order) {
                      final orderId = order['_id'] ?? '';
                      final totalAmount = order['totalAmount'] ?? 0;
                      final status = order['status'] ?? 'pending';
                      final fullName = order['shippingAddress']?['fullName'] ?? 'Khách hàng';
                      
                      String itemsStr = 'Bánh ngọt';
                      if (order['items'] != null && order['items'].isNotEmpty) {
                        itemsStr = order['items'][0]['product']?['name'] ?? 'Bánh ngọt';
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId))).then((_) => _loadDashboardData());
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(25),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/banner.png'), // placeholder
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('#ORD-${orderId.toString().substring(0,4).toUpperCase()} — $fullName', 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text('$itemsStr • ${formatCurrency(totalAmount)}', 
                                      style: const TextStyle(color: Color(0xFF718096), fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: FormatUtils.getStatusBgColor(status),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(FormatUtils.formatStatus(status).toUpperCase(), 
                                        style: TextStyle(color: FormatUtils.getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 32),
                  const Text('Thống kê Bánh bán chạy', style: TextStyle(fontSize: 16, color: Color(0xFF4A5568), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (_revenue != null && _revenue!['topProducts'] != null && (_revenue!['topProducts'] as List).isNotEmpty)
                    ...(_revenue!['topProducts'] as List).map((prod) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prod['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Đã bán: ${prod['totalSold']} chiếc', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                            Text(formatCurrency(prod['revenue']), style: const TextStyle(color: Color(0xFF0F5A3E), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }).toList()
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20), 
                        child: Text('Chưa có thống kê. Dữ liệu sẽ chính xác hơn khi có nhiều đơn hàng.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic), textAlign: TextAlign.center,)
                      )
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    Color bgColor = Colors.white,
    bool subtitleUnderline = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: bgColor == Colors.white 
            ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))]
            : [],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF718096), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 28, color: Color(0xFF2D3748))),
              const SizedBox(height: 12),
              Text(
                subtitle, 
                style: TextStyle(
                  color: subtitleColor, 
                  fontSize: 13, 
                  fontWeight: FontWeight.w600,
                  decoration: subtitleUnderline ? TextDecoration.underline : TextDecoration.none,
                )
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
          )
        ],
      ),
    );
  }
}
