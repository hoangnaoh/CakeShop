import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AdminHelpSupportScreen extends StatelessWidget {
  const AdminHelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ', style: TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neutral),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.help_outline, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text('Xin chào! Chúng tôi có thể giúp gì cho bạn?', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.neutral)),
            const SizedBox(height: 8),
            const Text('Tìm câu trả lời hoặc liên hệ với đội ngũ hỗ trợ của chúng tôi.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            
            _buildFaqItem('Làm sao để tôi duyệt đơn hàng mới?', 'Bạn hãy vào mục Đơn hàng, tìm các đơn có trạng thái "Chờ xử lý" và bấm nút "Duyệt đơn".'),
            _buildFaqItem('Tôi muốn thêm sản phẩm mới thì làm thế nào?', 'Bạn hãy vào mục Kho Bánh, bấm nút "Thêm Bánh" màu xanh ở góc phải phía trên màn hình.'),
            _buildFaqItem('Làm sao để xuất báo cáo doanh thu?', 'Tính năng xuất báo cáo doanh thu đang được chúng tôi phát triển và sẽ sớm ra mắt trong phiên bản tới.'),
            
            const SizedBox(height: 40),
            const Text('Vẫn cần hỗ trợ?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.neutral)),
            const SizedBox(height: 16),
            _buildContactItem(Icons.email_outlined, 'support@cakeshop.com'),
            _buildContactItem(Icons.phone_outlined, '1900 1234 5678'),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
        children: [
          Text(answer, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
