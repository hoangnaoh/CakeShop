import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/api_service.dart';
import 'home_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isAdmin;
  const NotificationsScreen({super.key, this.isAdmin = false});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await ApiService.getNotifications();
    if (mounted) {
      final List<dynamic> generatedNotifs = [];
      for (var notif in list) {
        final String type = notif['type'] ?? 'SYSTEM';
        final String title = notif['title'] ?? 'Thông báo';
        final String message = notif['message'] ?? '';

        IconData icon = Icons.notifications;
        Color color = AppColors.primary;

        switch (type) {
          case 'ORDER_CONFIRMATION':
          case 'ORDER_CONFIRMED':
            icon = Icons.receipt_long;
            color = Colors.blue;
            break;
          case 'NEW_ORDER':
            icon = Icons.shopping_bag;
            color = Colors.orange;
            break;
          case 'ORDER_SHIPPING':
            icon = Icons.local_shipping;
            color = Colors.purple;
            break;
          case 'ORDER_DELIVERED':
            icon = Icons.check_circle;
            color = Colors.green;
            break;
          default:
            icon = Icons.notifications;
            color = AppColors.primary;
            break;
        }

        generatedNotifs.add({
          'title': title,
          'message': message,
          'icon': icon,
          'color': color,
          'createdAt': notif['createdAt'],
        });
      }

      setState(() {
        _notifications = generatedNotifs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.secondary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const HomeScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty 
              ? const Center(child: Text('Bạn chưa có thông báo nào'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final String title = notif['title'] ?? 'Thông báo';
                    final String body = notif['message'] ?? '';
                    final IconData icon = notif['icon'] ?? Icons.notifications;
                    final Color color = notif['color'] ?? AppColors.primary;
                    
                    String timeAgo = 'Vừa xong';
                    if (notif['createdAt'] != null) {
                      final date = DateTime.tryParse(notif['createdAt'].toString());
                      if (date != null) {
                        final diff = DateTime.now().difference(date);
                        if (diff.inDays > 0) {
                          timeAgo = '${diff.inDays} ngày trước';
                        } else if (diff.inHours > 0) {
                          timeAgo = '${diff.inHours} giờ trước';
                        } else if (diff.inMinutes > 0) {
                          timeAgo = '${diff.inMinutes} phút trước';
                        }
                      }
                    }

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      color: AppColors.surface,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.1),
                          child: Icon(icon, color: color),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                            Text(timeAgo, style: TextStyle(color: AppColors.neutral.withOpacity(0.5), fontSize: 12)),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(body, style: const TextStyle(fontSize: 13)),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
      bottomNavigationBar: widget.isAdmin ? null : const BottomNavBar(selectedIndex: 2),
    );
  }
}
