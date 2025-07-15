// service/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static const String baseUrl = 'http://mediquick.my.id';

  /// Mengirim data pesanan dan mendapatkan Snap URL dari Midtrans
  static Future<Map<String, dynamic>> createOrderAndGetSnap({
    required String userId,
    required int apotekId,
    required String name,
    required String email,
    required String phone,
    required String address,
    String? note,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      print(
        "KIRIM DATA PESANAN: ${jsonEncode({'user_id': userId, 'apotek_profile_id': apotekId, 'name': name, 'email': email, 'phone': phone, 'address': address, 'note': note ?? '', 'items': items})}",
      );

      final response = await http.post(
        Uri.parse('$baseUrl/payment/snap_token.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'apotek_profile_id': apotekId, // ✅ ini yang sesuai dengan PHP backend
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'note': note ?? '',
          'items': items,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message':
              'Gagal menghubungi server. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengirim pesanan: $e',
      };
    }
  }
}
