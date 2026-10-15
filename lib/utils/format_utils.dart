import 'package:flutter/material.dart';

class FormatUtils {
  static String formatCurrency(dynamic amount) {
    if (amount == null) return '0đ';
    final intValue = double.tryParse(amount.toString())?.toInt() ?? 0;
    final formatted = intValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$formattedđ';
  }

  static String formatOrderId(String? id) {
    if (id == null || id.isEmpty) return '#ORD-UNKNOWN';
    final shortId = id.length >= 6 ? id.substring(id.length - 6) : id;
    return '#ORD-${shortId.toUpperCase()}';
  }
  
  static String formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Chờ duyệt';
      case 'confirmed': return 'Đã duyệt';
      case 'shipping': return 'Đang giao';
      case 'completed': 
      case 'delivered': return 'Hoàn thành';
      case 'cancelled': 
      case 'canceled': return 'Đã hủy';
      default: return status.toUpperCase();
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFD97706); // Amber
      case 'confirmed': return const Color(0xFF2563EB); // Blue
      case 'shipping': return const Color(0xFF7C3AED); // Purple
      case 'completed': 
      case 'delivered': return const Color(0xFF059669); // Green
      case 'cancelled': 
      case 'canceled': return const Color(0xFFDC2626); // Red
      default: return const Color(0xFF4B5563); // Gray
    }
  }

  static Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFFEF3C7);
      case 'confirmed': return const Color(0xFFDBEAFE);
      case 'shipping': return const Color(0xFFEDE9FE);
      case 'completed': 
      case 'delivered': return const Color(0xFFD1FAE5);
      case 'cancelled': 
      case 'canceled': return const Color(0xFFFEE2E2);
      default: return const Color(0xFFF3F4F6);
    }
  }
}
