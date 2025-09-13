import 'package:flutter/material.dart';
import 'package:g2railsample/services/payment_service.dart';
import 'package:g2railsample/pages/home_page.dart';

void main() {
  PaymentService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'G2Rail Travel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
