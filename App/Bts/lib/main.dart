import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:g2railsample/services/payment_service.dart';
import 'package:g2railsample/pages/home_page.dart';
import 'repos/product_repo.dart';
import 'services/subscription_service.dart';

void main() {
  PaymentService.initialize();
  final repo = InMemoryProductRepo();
  final subscriptionService = SubscriptionService(
    baseUrl: 'https://api.dodoman-travel.com', // Replace with actual API endpoint
    httpClient: http.Client(),
  );
  runApp(MyApp(
    repo: repo,
    subscriptionService: subscriptionService,
  ));
}

class MyApp extends StatelessWidget {
  final ProductRepo repo;
  final SubscriptionService subscriptionService;

  const MyApp({
    super.key,
    required this.repo,
    required this.subscriptionService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DoDoMan Travel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomePage(
        repo: repo,
        subscriptionService: subscriptionService,
      ),
    );
  }
}
