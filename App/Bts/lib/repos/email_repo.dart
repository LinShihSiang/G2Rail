import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailRepo {
  final String apiUrl;
  final String apiKey;

  EmailRepo({
    required this.apiUrl,
    required this.apiKey,
  });

  Future<bool> sendConfirmationEmail({
    required String toEmail,
    required String customerName,
    required String orderDetails,
    required String paymentDetails,
  }) async {
    // TODO: Implement email service integration (SendGrid, AWS SES, etc.)
    // This is a placeholder implementation
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/send-email'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'to': toEmail,
          'subject': 'G2Rail Travel Booking Confirmation',
          'body': _buildConfirmationEmailBody(customerName, orderDetails, paymentDetails),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Email sending failed: $e');
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

    Thank you for booking with G2Rail Travel!

    Your booking has been confirmed. Here are the details:

    $orderDetails

    Payment Details:
    $paymentDetails

    We look forward to serving you on your journey.

    Best regards,
    G2Rail Travel Team
    ''';
  }
}