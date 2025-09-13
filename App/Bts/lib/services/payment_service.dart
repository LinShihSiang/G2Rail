import 'package:g2railsample/repos/payment_repo.dart';

class PaymentService {
  static void initialize() {
    PaymentRepo.initialize();
  }

  static Future<bool> processTicketPayment({
    required double ticketPrice,
    required String travelDescription,
  }) async {
    try {
      return await PaymentRepo.processPaymentWithSheet(
        amount: ticketPrice,
        currency: 'usd',
        description: travelDescription,
      );
    } catch (e) {
      throw Exception('Payment processing failed: $e');
    }
  }

  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String description,
  }) async {
    final amountInCents = (amount * 100).round().toString();
    return await PaymentRepo.createPaymentIntent(
      amount: amountInCents,
      currency: currency,
      description: description,
    );
  }

  static Future<bool> confirmPayment({
    required String clientSecret,
  }) async {
    return await PaymentRepo.processPayment(clientSecret: clientSecret);
  }
}