import 'package:g2railsample/repos/email_repo.dart';

class EmailService {
  final EmailRepo _emailRepo;

  EmailService({
    required String apiUrl,
    required String apiKey,
  }) : _emailRepo = EmailRepo(apiUrl: apiUrl, apiKey: apiKey);

  Future<bool> sendBookingConfirmation({
    required String customerEmail,
    required String customerName,
    required Map<String, dynamic> bookingDetails,
    required Map<String, dynamic> paymentInfo,
  }) async {
    final orderDetails = _formatBookingDetails(bookingDetails);
    final paymentDetails = _formatPaymentDetails(paymentInfo);

    return await _emailRepo.sendConfirmationEmail(
      toEmail: customerEmail,
      customerName: customerName,
      orderDetails: orderDetails,
      paymentDetails: paymentDetails,
    );
  }

  String _formatBookingDetails(Map<String, dynamic> booking) {
    return '''
Travel Route: ${booking['from']} → ${booking['to']}
Date: ${booking['date']}
Time: ${booking['time']}
Passengers: ${booking['passengers']}
Ticket Type: ${booking['ticketType'] ?? 'Standard'}
''';
  }

  String _formatPaymentDetails(Map<String, dynamic> payment) {
    return '''
Amount: \$${payment['amount']?.toStringAsFixed(2) ?? '0.00'} ${payment['currency']?.toUpperCase() ?? 'USD'}
Payment Method: ${payment['method'] ?? 'Credit Card'}
Transaction ID: ${payment['transactionId'] ?? 'N/A'}
Date: ${DateTime.now().toString().split('.')[0]}
''';
  }
}