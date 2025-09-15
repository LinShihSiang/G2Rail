import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EmailRepo {
  EmailRepo();

  Future<bool> sendConfirmationEmail({
    required String toEmail,
    required String customerName,
    required String orderDetails,
    required String paymentDetails,
    String? subject,
  }) async {

    try {
      final title = 'DoDoMan order - {$customerName}($toEmail)';

      final response = await http.post(
        Uri.parse(
          'https://howardmei.app.n8n.cloud/webhook/send-order-mail',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'subject': title,
          'message': _buildConfirmationEmailBody(customerName, orderDetails, paymentDetails)
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw 'Request timeout after 30 seconds',
      );

      if (response.statusCode != 200) {
        throw 'HTTP ${response.statusCode}: ${response.body}';
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Email sending failed: $e');
      }
      return false;
    }
  }


  String _buildConfirmationEmailBody(
    String customerName,
    String orderDetails,
    String paymentDetails,
  ) {
    return '''
    Dear $customerName,

    Thank you for booking with DoDoMan Travel!

    Your booking has been confirmed. Here are the details:

    $orderDetails

    Payment Details:
    $paymentDetails

    We look forward to serving you on your journey.

    Best regards,
    DoDoMan Travel Team
    ''';
  }
}