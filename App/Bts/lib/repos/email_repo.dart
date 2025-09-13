import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/services.dart';
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
    // In debug/development mode, skip trying to send email and just log it
    if (kDebugMode) {
      debugPrint('📧 EMAIL SIMULATION (Development Mode)');
      debugPrint('To: $toEmail');
      debugPrint('Subject: ${subject ?? 'DoDoMan Travel Booking Confirmation'}');
      debugPrint('Body:\n${_buildConfirmationEmailBody(customerName, orderDetails, paymentDetails)}');
      debugPrint('✅ Email would be sent successfully in production');
      return true;
    }

    try {
      final Email email = Email(
        body: _buildConfirmationEmailBody(customerName, orderDetails, paymentDetails),
        subject: subject ?? 'DoDoMan Travel Booking Confirmation',
        recipients: [toEmail],
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
      debugPrint('✅ Email sent successfully to $toEmail');
      return true;
    } on PlatformException catch (e) {
      if (e.code == 'not_available') {
        debugPrint('❌ Email sending failed: No email clients found on device');
        debugPrint('💡 In production, ensure users have an email app installed');
        return false; // In production, this should return false to indicate failure
      } else {
        debugPrint('❌ Email sending failed with platform exception: ${e.message}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Email sending failed with unexpected error: $e');
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