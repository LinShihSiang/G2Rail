import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OrderApiService {
  static const String _baseUrl = 'https://howardmei.app.n8n.cloud/webhook/set-order';

  Future<bool> submitOrder({
    required String orderId,
    required DateTime orderDate,
    required String customerName,
    required String orderDetails,
    required double orderAmount,
    required String paymentMethod,
    required String paymentStatus,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': orderId,
          'date': orderDate.toIso8601String(),
          'name': customerName,
          'message': orderDetails,
          'pay': orderAmount,
          'method': paymentMethod,
          'status': paymentStatus,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Order submitted successfully: ${response.body}');
        return true;
      } else {
        debugPrint('Failed to submit order. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting order: $e');
      return false;
    }
  }
}
