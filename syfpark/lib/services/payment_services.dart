import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static Future<Map<String, dynamic>> initiateMPesaPayment({
    required String plateNumber,
    required String phoneNumber,
    required String paymentApiUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(paymentApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'carnumber': plateNumber,
          'mobilenumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        print('MPesa STK push initiated successfully for $plateNumber');
        return jsonDecode(response.body) ?? {'status': 'success'};
      } else {
        throw Exception('Payment failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error initiating MPesa payment: $e');
      throw Exception('Error initiating payment: $e');
    }
  }
}