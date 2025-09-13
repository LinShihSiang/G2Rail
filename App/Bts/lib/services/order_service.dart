import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:g2railsample/repos/travel_repo.dart';
import 'package:g2railsample/repos/email_repo.dart';

class OrderService {
  late final TravelRepo _travelRepo;
  late final EmailRepo _emailRepo;

  OrderService() {
    _travelRepo = TravelRepo(
      httpClient: _createHttpClient(),
      baseUrl: "http://alpha-api.g2rail.com",
      apiKey: "<API-Key>", // TODO: Move to environment variables
      secret: "<API-Secret>", // TODO: Move to environment variables
    );

    _emailRepo = EmailRepo();
  }

  Client _createHttpClient() {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback =
        (cert, host, port) => true; // TODO: Fix SSL validation for production
    return IOClient(httpClient);
  }

  Future<List<dynamic>> searchTravelOptions({
    required String from,
    required String to,
    required String date,
    required String time,
    required int adult,
    required int child,
    required int junior,
    required int senior,
    required int infant,
  }) async {
    try {
      final result = await _travelRepo.getSolutions(
        from,
        to,
        date,
        time,
        adult,
        child,
        junior,
        senior,
        infant,
      );
      return result['solutions'] ?? [];
    } catch (e) {
      throw Exception('Failed to search travel options: $e');
    }
  }

  Future<void> sendOrderConfirmation({
    required String customerEmail,
    required String customerName,
    required String orderDetails,
    required String paymentDetails,
  }) async {
    await _emailRepo.sendConfirmationEmail(
      toEmail: customerEmail,
      customerName: customerName,
      orderDetails: orderDetails,
      paymentDetails: paymentDetails,
    );
  }
}