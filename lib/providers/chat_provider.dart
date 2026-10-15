import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<Map<String, dynamic>> _messages = [];
  String _customerName = 'Khách hàng';
  int _unreadCountForAdmin = 0;
  String? _conversationId;
  List<dynamic> _adminConversations = [];

  List<Map<String, dynamic>> get messages => _messages;
  String get customerName => _customerName;
  int get unreadCountForAdmin => _unreadCountForAdmin;
  String? get conversationId => _conversationId;
  List<dynamic> get adminConversations => _adminConversations;

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void markAsReadForAdmin() {
    _unreadCountForAdmin = 0;
    notifyListeners();
  }

  // Load conversation and messages for customer
  Future<void> loadConversationForCustomer() async {
    final convo = await ApiService.getMyConversation();
    if (convo != null) {
      _conversationId = convo['_id'];
      if (convo['customer'] != null) {
        _customerName = convo['customer']['fullName'] ?? 'Khách hàng';
      }
      await loadMessages(_conversationId!);
    }
  }

  // Load conversation list for Admin
  Future<void> loadConversationsForAdmin() async {
    final list = await ApiService.getConversations();
    _adminConversations = list;
    notifyListeners();
  }

  // Load messages for a given conversation
  Future<void> loadMessages(String convoId) async {
    _conversationId = convoId;
    final msgs = await ApiService.getMessages(convoId);
    _messages = msgs.map((m) {
      return {
        'text': m['text'] ?? '',
        'isUser': m['senderRole'] == 'customer',
      };
    }).toList();
    notifyListeners();
  }

  // Send message
  Future<void> addMessage(String text, {required bool isUser, String? adminConvoId}) async {
    final targetConvoId = adminConvoId ?? _conversationId;
    if (targetConvoId == null) {
      // For customer, if conversation doesn't exist yet, we try to load/create it
      await loadConversationForCustomer();
    }

    final activeConvoId = adminConvoId ?? _conversationId;
    if (activeConvoId != null) {
      // Optimistically add to UI
      _messages.add({'text': text, 'isUser': !isUser ? false : true});
      if (isUser) {
        _unreadCountForAdmin++;
      }
      notifyListeners();

      // Persist to backend
      await ApiService.sendChatMessage(activeConvoId, text);
    }
  }
}
