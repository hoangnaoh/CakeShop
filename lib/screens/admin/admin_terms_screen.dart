import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AdminTermsScreen extends StatelessWidget {
  const AdminTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        title: const Text('Điều khoản sử dụng', style: TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neutral),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chính sách & Điều khoản', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              SizedBox(height: 16),
              Text('Cập nhật lần cuối: 20/06/2026', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
              SizedBox(height: 24),
              
              Text('1. Giới thiệu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('Chào mừng bạn đến với ứng dụng quản lý CakeShop. Khi sử dụng ứng dụng này, bạn đồng ý tuân thủ các điều khoản và điều kiện được mô tả dưới đây.', style: TextStyle(height: 1.5)),
              SizedBox(height: 24),

              Text('2. Quyền lợi và Trách nhiệm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('Với tư cách là Quản trị viên (Admin), bạn có quyền truy cập vào thông tin khách hàng, doanh thu và dữ liệu kho hàng. Bạn có trách nhiệm bảo mật tuyệt đối các thông tin này và không chia sẻ cho bên thứ ba.', style: TextStyle(height: 1.5)),
              SizedBox(height: 24),

              Text('3. Xử lý Đơn hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('Admin phải đảm bảo xử lý đơn hàng theo đúng quy trình và đúng hạn. Mọi hành vi thao tác sai lệch dữ liệu hệ thống sẽ được ghi nhận và có thể dẫn đến việc khóa tài khoản.', style: TextStyle(height: 1.5)),
              SizedBox(height: 24),

              Text('4. Quyền Sở Hữu Trí Tuệ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('Toàn bộ mã nguồn, giao diện thiết kế và cơ sở dữ liệu của CakeShop thuộc bản quyền sở hữu của công ty. Mọi hành vi sao chép đều vi phạm pháp luật.', style: TextStyle(height: 1.5)),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
