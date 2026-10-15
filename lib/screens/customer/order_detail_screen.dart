import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'chat_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/app_colors.dart';

import '../../utils/format_utils.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    final order = await ApiService.getOrderById(widget.orderId);
    if (mounted && order != null) {
      setState(() {
        _order = order;
        _isLoading = false;
      });

      if (order['status'] == 'Delivered') {
        final items = order['items'] as List<dynamic>? ?? [];
        final List<String> productIds = items
            .map((item) {
              final prod = item['product'];
              return prod is Map ? prod['_id']?.toString() : prod?.toString();
            })
            .whereType<String>()
            .toList();

        if (productIds.isNotEmpty) {
          Provider.of<ReviewProvider>(context, listen: false)
              .checkIfOrderReviewed(widget.orderId, productIds);
        }
      }
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.secondary,
        appBar: AppBar(
          title: const Text('Chi tiết đơn hàng', style: TextStyle(color: AppColors.primary)), 
          backgroundColor: AppColors.secondary, 
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_order == null) {
      return Scaffold(
        backgroundColor: AppColors.secondary,
        appBar: AppBar(
          title: const Text('Chi tiết đơn hàng', style: TextStyle(color: AppColors.primary)), 
          backgroundColor: AppColors.secondary, 
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary),
        ),
        body: const Center(child: Text('Không tìm thấy đơn hàng')),
      );
    }

    final items = _order!['items'] as List<dynamic>? ?? [];
    final address = _order!['shippingAddress'] ?? {};
    final totalAmount = FormatUtils.formatCurrency(_order!['totalAmount']);
    final status = FormatUtils.formatStatus(_order!['status'] ?? 'pending');
    final formattedId = FormatUtils.formatOrderId(widget.orderId);

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mã đơn hàng', style: TextStyle(fontSize: 16, color: AppColors.neutral)),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.orderId.toUpperCase()));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã copy mã đơn hàng')));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Text(formattedId, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1.5, color: AppColors.primary)),
                        const SizedBox(width: 8),
                        const Icon(Icons.copy, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Trạng thái đơn hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(status.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FormatUtils.getStatusColor(_order!['status'] ?? 'pending'))),
                  const SizedBox(height: 16),
                  _buildTimeline(_order!['status'] ?? 'Pending', (address['address'] ?? '') == 'Nhận bánh tại cửa hàng'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Sản phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            ...items.map((item) {
              final product = item['product'] ?? {};
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.cake, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('${product['name'] ?? 'Bánh'} (x${item['quantity'] ?? 1})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text(FormatUtils.formatCurrency(item['price']), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            const Text('Địa chỉ giao hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address['fullName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(address['phone'] ?? ''),
                  Text(address['address'] ?? ''),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng thanh toán:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(totalAmount, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Phương thức:', style: TextStyle(fontSize: 16)),
                Text(_order!['paymentMethod'] == 'EMVCo' ? 'Chuyển khoản (VietQR)' : 'Tiền mặt (COD)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tình trạng thanh toán:', style: TextStyle(fontSize: 16)),
                Text(_order!['paymentStatus'] == 'Paid' ? 'ĐÃ THANH TOÁN' : 'CHƯA THANH TOÁN', 
                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _order!['paymentStatus'] == 'Paid' ? Colors.green : Colors.red)),
              ],
            ),
            const SizedBox(height: 32),
            // Admin Controls
            FutureBuilder<Map<String, dynamic>?>(
              future: ApiService.getUserProfile(),
              builder: (context, snapshot) {
                final roles = snapshot.data?['roles'] as List? ?? ['customer'];
                final isAdmin = roles.contains('admin') || roles.contains('shop') || roles.contains('lender');
                
                if (!isAdmin) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                              label: const Text('Chat với shop', style: TextStyle(color: AppColors.primary)),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
                              label: const Text('Mua lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_order!['status'] == 'Delivered') ...[
                        const SizedBox(height: 16),
                        Consumer<ReviewProvider>(
                          builder: (context, reviewProvider, child) {
                            final hasReviewed = reviewProvider.hasReviewed(widget.orderId);
                            if (hasReviewed) {
                              final review = reviewProvider.getReview(widget.orderId);
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('Bạn đã đánh giá: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                                        Row(
                                          children: List.generate(5, (index) => Icon(
                                            index < (review?['rating'] ?? 5) ? Icons.star : Icons.star_border,
                                            color: Colors.orange, size: 16
                                          )),
                                        ),
                                      ],
                                    ),
                                    if (review?['comment'] != null && review!['comment'].toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text('"${review['comment']}"', style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.neutral)),
                                      ),
                                  ],
                                ),
                              );
                            }
                            return ElevatedButton.icon(
                              icon: const Icon(Icons.star_outline, color: Colors.white),
                              label: const Text('Đánh giá sản phẩm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              onPressed: () => _showReviewDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                              ),
                            );
                          },
                        ),
                      ]
                    ],
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Khu vực Admin: Cập nhật Trạng thái', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                          Consumer<ChatProvider>(
                            builder: (context, chatProvider, child) {
                              final unreadCount = chatProvider.unreadCountForAdmin;
                              return Badge(
                                label: unreadCount > 0 ? Text('$unreadCount') : null,
                                isLabelVisible: unreadCount > 0,
                                child: IconButton(
                                  icon: const Icon(Icons.chat, color: AppColors.primary),
                                  tooltip: 'Chat với Khách hàng',
                                  onPressed: () {
                                    final customerName = _order!['customer']?['fullName'] ?? _order!['shippingAddress']?['fullName'] ?? 'Khách hàng';
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(isAdmin: true, userName: customerName)));
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_order!['status'] == 'Pending') ...[
                            _buildStatusBtn('Duyệt đơn', 'Confirmed', Colors.blue),
                            _buildCancelBtn(),
                          ] else if (_order!['status'] == 'Confirmed') ...[
                            if ((_order!['shippingAddress']?['address'] ?? '') == 'Nhận bánh tại cửa hàng')
                              _buildStatusBtn('Hoàn thành (Khách đã nhận)', 'Delivered', Colors.green)
                            else
                              _buildStatusBtn('Đang giao', 'Shipping', Colors.orange),
                            _buildCancelBtn(),
                          ] else if (_order!['status'] == 'Shipping') ...[
                            _buildStatusBtn('Hoàn thành', 'Delivered', Colors.green),
                            _buildCancelBtn(),
                          ] else if (_order!['status'] == 'Delivered') ...[
                            const Padding(
                               padding: EdgeInsets.symmetric(vertical: 8),
                               child: Text('Đơn hàng đã hoàn thành, không thể thay đổi.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                            ),
                          ] else if (_order!['status'] == 'Canceled') ...[
                            const Padding(
                               padding: EdgeInsets.symmetric(vertical: 8),
                               child: Text('Đơn hàng đã hủy.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                            ),
                          ],
                        ],
                      )
                    ],
                  ),
                );
              }
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBtn(String label, String statusValue, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
      onPressed: () async {
        final success = await ApiService.updateOrderStatus(widget.orderId, statusValue);
        if (success) {
          _loadOrderDetail();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật trạng thái: $label')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại!'), backgroundColor: Colors.red));
        }
      },
      child: Text(label),
    );
  }

  Widget _buildCancelBtn() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận hủy đơn'),
            content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không? Hành động này không thể hoàn tác.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context); // Close dialog
                  final success = await ApiService.updateOrderStatus(widget.orderId, 'Canceled');
                  if (success) {
                    _loadOrderDetail();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy đơn hàng')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hủy thất bại. Vui lòng thử lại!'), backgroundColor: Colors.red));
                  }
                },
                child: const Text('Hủy đơn', style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        );
      },
      child: const Text('Hủy đơn'),
    );
  }

  void _showReviewDialog(BuildContext context) {
    int rating = 5;
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Đánh giá sản phẩm', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Vui lòng đánh giá trải nghiệm của bạn với đơn hàng này:'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Nhập nhận xét của bạn...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final items = _order!['items'] as List<dynamic>? ?? [];
                    final productIds = items.map((e) => e['product']?['_id']?.toString() ?? e['productId']?.toString() ?? '').where((id) => id.isNotEmpty).toList();
                    final provider = Provider.of<ReviewProvider>(context, listen: false);
                    provider.addReview(widget.orderId, productIds, rating, commentController.text);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cảm ơn bạn đã đánh giá!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Gửi đánh giá', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildTimeline(String currentStatus, bool isPickup) {
    int step = 0;
    if (currentStatus == 'Confirmed') step = 1;
    else if (currentStatus == 'Shipping') step = 2;
    else if (currentStatus == 'Delivered') step = 3;
    else if (currentStatus == 'Canceled') step = -1;

    if (step == -1) return const SizedBox(); // Không hiện timeline nếu đã hủy

    if (isPickup) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimelineStep('Đặt hàng', step >= 0),
          _buildTimelineLine(step >= 1),
          _buildTimelineStep('Duyệt', step >= 1),
          _buildTimelineLine(step >= 3),
          _buildTimelineStep('Hoàn thành', step >= 3),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimelineStep('Đặt hàng', step >= 0),
        _buildTimelineLine(step >= 1),
        _buildTimelineStep('Duyệt', step >= 1),
        _buildTimelineLine(step >= 2),
        _buildTimelineStep('Giao hàng', step >= 2),
        _buildTimelineLine(step >= 3),
        _buildTimelineStep('Hoàn thành', step >= 3),
      ],
    );
  }

  Widget _buildTimelineStep(String title, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? AppColors.primary : Colors.grey[300],
          child: isActive ? const Icon(Icons.check, size: 16, color: Colors.white) : const SizedBox(),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 10, color: isActive ? AppColors.primary : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildTimelineLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isActive ? AppColors.primary : Colors.grey[300],
      ),
    );
  }
}
