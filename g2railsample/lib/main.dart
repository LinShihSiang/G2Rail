import 'dart:io';

import 'package:flutter/material.dart';
import 'package:g2railsample/g2rail_api_client.dart';
import 'package:g2railsample/stripe_service.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

void main() {
  StripeService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isPaymentProcessing = false;
  final double _ticketPrice = 89.99;

  Client baseClient() {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          return true;
        };
    Client c = IOClient(httpClient);
    return c;
  }

  void _actAPI() async {
    String baseUrl = "http://alpha-api.g2rail.com";
    var gac = GrailApiClient(
      httpClient: baseClient(),
      baseUrl: baseUrl,
      apiKey: "<API-Key>",
      secret: "<API-Secret>",
    );
    var rtn = await gac.getSolutions(
      "Frankfurt",
      "Berlin",
      DateFormat(
        "yyyy-MM-dd",
      ).format(DateTime.now().add(const Duration(days: 7))),
      "08:00",
      1,
      0,
      0,
      0,
      0,
    );
  }

  void _payForTicket() async {
    if (_isPaymentProcessing) return;

    setState(() {
      _isPaymentProcessing = true;
    });

    try {
      final success = await StripeService.payForTravelTicket(
        ticketPrice: _ticketPrice,
        travelDescription: 'Travel ticket from Frankfurt to Berlin',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Your ticket is confirmed.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isPaymentProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'G2Rail Travel Booking',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Frankfurt → Berlin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7))),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Text('08:00 Departure', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    Text(
                      '\$${_ticketPrice.toStringAsFixed(2)} USD',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isPaymentProcessing ? null : _payForTicket,
                      icon: _isPaymentProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2)
                            )
                          : const Icon(Icons.credit_card),
                      label: Text(_isPaymentProcessing ? 'Processing...' : 'Pay with Credit Card'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _actAPI,
        tooltip: 'Go',
        child: const Icon(Icons.add),
      ),
    );
  }
}
