import 'package:flutter/material.dart';
import 'package:g2railsample/services/payment_service.dart';
import 'package:g2railsample/pages/home_page.dart';
import 'repos/product_repo.dart';

void main() {
  PaymentService.initialize();
  final repo = InMemoryProductRepo();
  runApp(MyApp(repo: repo));
}

class MyApp extends StatelessWidget {
  final ProductRepo repo;
  const MyApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Agency',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomePage(repo: repo),
    );
  }
}
