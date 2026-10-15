import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ApiService {
  // Đã deploy BE lên Render - dùng chung cho cả Web, Android và iOS
  static const String baseUrl = 'https://cakeshop-xq48.onrender.com/api/v1';
  static String? authToken; // Token để dùng cho các API yêu cầu auth (ví dụ tạo Order)
  static ValueNotifier<int> notificationCount = ValueNotifier<int>(0); // Global notification count

  // 1. Fetch danh sách sản phẩm
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final rawData = data['data'];
          List list = [];
          if (rawData is List) {
            list = rawData;
          } else if (rawData is Map && rawData.containsKey('docs')) {
            list = rawData['docs'];
          }
          return list.map((e) => Product.fromJson(e)).toList();
        }
      }
      throw Exception('Lỗi lấy danh sách sản phẩm');
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // 2. Login tạm để lấy token
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          authToken = data['data']['accessToken']; // lưu token
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // 1b. Register
  static Future<bool> register(String email, String password, String fullName, String roleChoice) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'roleChoice': roleChoice
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        authToken = data['data']['accessToken'];
        return true;
      }
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  // 3. Tạo đơn hàng (Checkout)
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String paymentMethod, // 'COD' hoặc 'EMVCo'
    required String name,
    required String phone,
    required String address,
    double shippingFee = 0.0,
    String? voucherCode,
    int usePoints = 0,
  }) async {
    if (authToken == null) {
      return {'success': false, 'message': 'Bạn chưa đăng nhập'};
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'items': items,
          'paymentMethod': paymentMethod,
          'shippingAddress': {
            'fullName': name,
            'phone': phone,
            'address': address,
          },
          'shippingFee': shippingFee,
          'note': 'Order from App',
          if (voucherCode != null) 'voucherCode': voucherCode,
          'usePoints': usePoints,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print('Checkout error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 4. Lấy thông tin tài khoản ngân hàng của Admin
  static Future<Map<String, dynamic>?> getAdminBankInfo() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/settings/bank'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'];
      }
      return null;
    } catch (e) {
      print('Get bank info error: $e');
      return null;
    }
  }

  // 5. Cập nhật tài khoản ngân hàng (Yêu cầu quyền Admin)
  static Future<Map<String, dynamic>> updateAdminBankInfo(String bin, String accountNumber, String accountName) async {
    if (authToken == null) return {'success': false, 'message': 'Chưa đăng nhập'};
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/settings/admin/bank'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'bin': bin,
          'accountNumber': accountNumber,
          'accountName': accountName,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Lấy địa chỉ cửa hàng
  static Future<Map<String, dynamic>?> getShopAddress() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/settings/shop-address'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'];
      }
      return null;
    } catch (e) {
      print('Get shop address error: $e');
      return null;
    }
  }

  // Cập nhật địa chỉ cửa hàng
  static Future<Map<String, dynamic>> updateShopAddress(String address, double lat, double lng) async {
    if (authToken == null) return {'success': false, 'message': 'Chưa đăng nhập'};
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/settings/admin/shop-address'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'address': address,
          'latitude': lat,
          'longitude': lng,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 6. Lấy profile người dùng (để xem điểm)
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (authToken == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'];
      }
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  // 6b. Cập nhật hồ sơ
  static Future<bool> updateProfile(String fullName, String phone) async {
    if (authToken == null) return false;
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fullName': fullName, 'phone': phone}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  // 6c. Đổi mật khẩu
  static Future<bool> updatePassword(String currentPassword, String newPassword) async {
    if (authToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'oldPassword': currentPassword,
          'newPassword': newPassword
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update password error: $e');
      return false;
    }
  }

  // 7. Validate Voucher
  static Future<Map<String, dynamic>> validateVoucher(String code, double orderValue) async {
    if (authToken == null) return {'success': false, 'message': 'Chưa đăng nhập'};
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vouchers/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'code': code,
          'orderValue': orderValue,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // 8. Lấy danh sách đánh giá sản phẩm
  static Future<Map<String, dynamic>> getProductReviews(String productId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reviews/product/$productId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'data': []};
    } catch (e) {
      print('Get reviews error: $e');
      return {'success': false, 'data': []};
    }
  }
  // Thêm đánh giá sản phẩm
  static Future<Map<String, dynamic>> addReview({
    required String orderId,
    required String productId,
    required int rating,
    required String comment,
  }) async {
    if (authToken == null) return {'success': false, 'message': 'Chưa đăng nhập'};
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'orderId': orderId,
          'productId': productId,
          'rating': rating,
          'comment': comment,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Add review error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // 9. Lấy danh sách thông báo
  static Future<List<dynamic>> getNotifications() async {
    if (authToken == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final rawData = data['data'];
          if (rawData is List) return rawData;
          if (rawData is Map && rawData['docs'] != null) return rawData['docs'];
        }
      }
      return [];
    } catch (e) {
      print('Get notifications error: $e');
      return [];
    }
  }

  // 10. Lấy danh sách đơn hàng của tôi
  static Future<List<dynamic>> getMyOrders() async {
    if (authToken == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/me'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final rawData = data['data'];
          if (rawData is List) return rawData;
          if (rawData is Map && rawData['docs'] != null) return rawData['docs'];
        }
      }
      return [];
    } catch (e) {
      print('Get my orders error: $e');
      return [];
    }
  }

  // 11. Lấy danh sách đơn hàng của Shop
  static Future<List<dynamic>> getShopOrders() async {
    if (authToken == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/shop/me'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final rawData = data['data'];
          if (rawData is List) return rawData;
          if (rawData is Map && rawData['docs'] != null) return rawData['docs'];
        }
      }
      return [];
    } catch (e) {
      print('Get shop orders error: $e');
      return [];
    }
  }

  // 12. Lấy doanh thu Shop
  static Future<Map<String, dynamic>?> getShopRevenue() async {
    if (authToken == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/shop/revenue'),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'];
      }
      return null;
    } catch (e) {
      print('Get shop revenue error: $e');
      return null;
    }
  }

  // 13. Lấy chi tiết đơn hàng
  static Future<Map<String, dynamic>?> getOrderById(String orderId, {bool forceSync = false}) async {
    if (authToken == null) return null;
    try {
      final url = forceSync
          ? '$baseUrl/orders/$orderId?forceSync=true'
          : '$baseUrl/orders/$orderId';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'];
      }
      return null;
    } catch (e) {
      print('Get order details error: $e');
      return null;
    }
  }

  // 14. Tạo sản phẩm mới (Admin)
  static Future<bool> createProduct({
    required String name,
    required String description,
    required String category,
    required double price,
    required int stock,
    required List<String> images,
    List<String> sizes = const [],
  }) async {
    if (authToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/shop/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'category': category,
          'price': price,
          'stock': stock,
          'images': images,
          'sizes': sizes,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Create product error: $e');
      return false;
    }
  }

  // 15. Cập nhật sản phẩm (Admin)
  static Future<bool> updateProduct({
    required String id,
    required String name,
    required String description,
    required String category,
    required double price,
    required int stock,
    required List<String> images,
    List<String> sizes = const [],
  }) async {
    if (authToken == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'category': category,
          'price': price,
          'stock': stock,
          'images': images,
          'sizes': sizes,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update product error: $e');
      return false;
    }
  }

  // 16. Xóa sản phẩm (Admin)
  static Future<bool> deleteProduct(String id) async {
    if (authToken == null) return false;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete product error: $e');
      return false;
    }
  }

  // 17. Cập nhật trạng thái đơn hàng (Admin)
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    if (authToken == null) return false;
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update order status error: $e');
      return false;
    }
  }
  // --- Chat APIs ---
  static Future<Map<String, dynamic>?> getMyConversation() async {
    if (authToken == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats/me'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          return resData['data'];
        }
      }
      return null;
    } catch (e) {
      print('Get my conversation error: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getConversations() async {
    if (authToken == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          return resData['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Get conversations error: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getMessages(String conversationId) async {
    if (authToken == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$conversationId/messages'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          return resData['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('Get messages error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> sendChatMessage(String conversationId, String text) async {
    if (authToken == null) return null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chats/$conversationId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'text': text}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          return resData['data'];
        }
      }
      return null;
    } catch (e) {
      print('Send chat message error: $e');
      return null;
    }
  }
}
