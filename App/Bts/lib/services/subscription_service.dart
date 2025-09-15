import 'dart:convert';
import 'package:http/http.dart' as http;
import '../repos/models/subscription_request.dart';
import '../repos/models/subscription_response.dart';

class SubscriptionService {
  final String baseUrl;
  final http.Client httpClient;

  SubscriptionService({
    required this.baseUrl,
    required this.httpClient,
  });

  Future<SubscriptionResponse> subscribe(SubscriptionRequest request) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return const SubscriptionResponse(
          success: true,
          message: 'Subscription successful! Thank you for subscribing.',
        );
      } else {
        return const SubscriptionResponse(
          success: false,
          message: 'Subscription failed. Please try again later.',
        );
      }
    } catch (e) {
      return const SubscriptionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}