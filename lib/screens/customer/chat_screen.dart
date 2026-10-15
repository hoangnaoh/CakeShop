import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';

import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final bool isAdmin;
  final String? userName;
  final String? conversationId;
  const ChatScreen({super.key, this.isAdmin = false, this.userName, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if (widget.isAdmin) {
        if (widget.userName != null) {
          chatProvider.setCustomerName(widget.userName!);
        }
        chatProvider.markAsReadForAdmin();
        if (widget.conversationId != null) {
          chatProvider.loadMessages(widget.conversationId!);
        }
      } else {
        _fetchAndSetUserName(chatProvider);
        chatProvider.loadConversationForCustomer();
      }
    });
  }

  Future<void> _fetchAndSetUserName(ChatProvider chatProvider) async {
    final profile = await ApiService.getUserProfile();
    if (profile != null && mounted) {
      final name = profile['fullName'] ?? 'Khách hàng';
      chatProvider.setCustomerName(name);
    }
  }

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;
    
    final provider = Provider.of<ChatProvider>(context, listen: false);
    provider.addMessage(
      _msgCtrl.text.trim(),
      isUser: !widget.isAdmin,
      adminConvoId: widget.isAdmin ? widget.conversationId : null,
    );
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ChatProvider>().messages;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Chat với ${context.watch<ChatProvider>().customerName}' : 'Chat với Shop', style: const TextStyle(color: AppColors.primary)),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['isUser'];
                final isMyMessage = widget.isAdmin ? !isUser : isUser;

                return Align(
                  alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMyMessage ? AppColors.primary : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(color: isMyMessage ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: widget.isAdmin ? null : const BottomNavBar(selectedIndex: 3),
    );
  }
}
