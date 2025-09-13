import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  static const String _publishableKey = 'pk_test_your_publishable_key_here';
  static const String _secretKey = 'sk_test_your_secret_key_here';
  static const String _baseUrl = 'https://api.stripe.com/v1';

  static void initialize() {
    Stripe.publishableKey = _publishableKey;
  }

  static Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'amount': amount,
          'currency': currency,
          'description': description,
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  static Future<bool> processPayment({
    required String clientSecret,
  }) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: 'Travel Customer',
            ),
          ),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Payment failed: $e');
      return false;
    }
  }

  static Future<bool> payForTravelTicket({
    required double ticketPrice,
    required String travelDescription,
  }) async {
    try {
      final amountInCents = (ticketPrice * 100).round().toString();

      final paymentIntent = await createPaymentIntent(
        amount: amountInCents,
        currency: 'usd',
        description: travelDescription,
      );

      final clientSecret = paymentIntent['client_secret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'G2Rail Travel',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      debugPrint('Payment error: $e');
      return false;
    }
  }
}