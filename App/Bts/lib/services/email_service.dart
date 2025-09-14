import 'package:g2railsample/repos/email_repo.dart';

class EmailService {
  final EmailRepo _emailRepo;

  EmailService() : _emailRepo = EmailRepo();

  Future<bool> sendBookingConfirmation({
    required String customerEmail,
    required String customerName,
    required Map<String, dynamic> bookingDetails,
    required Map<String, dynamic> paymentInfo,
  }) async {
    final subject = _createEmailSubject(bookingDetails);
    final body = _createEmailBody(bookingDetails, paymentInfo);

    return await _emailRepo.sendConfirmationEmail(
      toEmail: customerEmail,
      customerName: customerName,
      subject: subject,
      orderDetails: body,
      paymentDetails: '', // Already included in body
    );
  }

  String _createEmailSubject(Map<String, dynamic> booking) {
    final productName = booking['productName'] ?? 'Travel Booking';
    final customerName = booking['mainBookerName'] ?? 'Customer';
    return '$productName $customerName (DoDoMan)';
  }

  String _createEmailBody(Map<String, dynamic> booking, Map<String, dynamic> payment) {
    final companions = booking['companions'] as List? ?? [];
    final companionsList = companions.map((companion) =>
      '- ${companion['name']}${companion['ageIndicator'] ?? ''}'
    ).join('\n');

    return '''
Order Confirmation - ${booking['productName'] ?? 'Travel Booking'}

Order ID: ${booking['orderId']}
Date: ${DateTime.now().toString().split('.')[0]}

PURCHASER DETAILS:
Name: ${booking['mainBookerName']}
Email: ${booking['email']}

${companions.isNotEmpty ? 'COMPANIONS:\n$companionsList\n' : ''}
BOOKING DETAILS:
Product: ${booking['productName']}
Date: ${booking['dateTime']}
Adults: ${booking['adultCount']}
Children: ${booking['childCount']}
Unit Price: ${booking['unitPrice']} ${booking['currency']}
Total Amount: ${booking['totalAmount']} ${booking['currency']}

PAYMENT DETAILS:
Amount: ${payment['amount']} ${payment['currency']?.toString().toUpperCase()}
Payment Method: ${payment['method']}
Transaction ID: ${payment['transactionId']}
Date: ${DateTime.now().toString().split('.')[0]}

Thank you for your booking!
''';
  }

}