import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../customer/chat_screen.dart';
import '../../providers/chat_provider.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadConversationsForAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final conversations = chatProvider.adminConversations;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Tin nhắn hỗ trợ', style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.secondary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: conversations.isEmpty
          ? const Center(
              child: Text(
                'Chưa có cuộc hội thoại nào',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final convo = conversations[index];
                final customer = convo['customer'];
                final customerName = customer != null ? customer['fullName'] ?? 'Khách hàng' : 'Khách hàng';
                final lastMessage = convo['lastMessage'] ?? 'Chưa có tin nhắn';
                
                String timeStr = 'Vừa xong';
                if (convo['lastMessageAt'] != null) {
                  try {
                    final date = DateTime.parse(convo['lastMessageAt']).toLocal();
                    timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                  } catch (_) {}
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    title: Text(
                      customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(timeStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            isAdmin: true,
                            userName: customerName,
                            conversationId: convo['_id'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
