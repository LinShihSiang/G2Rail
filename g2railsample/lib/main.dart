import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:g2railsample/g2rail_api_client.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'G2Rail API Sample',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'G2Rail API Sample'),
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
  String _apiResponse = 'No API response yet';
  Client baseClient() {
    if (kIsWeb) {
      // For web platforms, use the default HTTP client
      return Client();
    } else {
      // For mobile/desktop platforms, use IOClient with certificate bypass
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
            return true;
          };
      return IOClient(httpClient);
    }
  }

  void _actAPI() async {
    setState(() {
      _apiResponse = 'Loading...';
    });
    
    try {
      String baseUrl = "http://alpha-api.g2rail.com";
      var gac = GrailApiClient(
        httpClient: baseClient(),
        baseUrl: baseUrl,
        apiKey: "fa656e6b99d64f309d72d6a8e7284953",
        secret: "9a52b1f7-7c96-4305-8569-1016a55048bc",
      );
      var rtn = await gac.getSolutions(
        "CT_LV7D4WNOK",
        "CT_60Y990YWR",
        DateFormat(
          "yyyy-MM-dd",
        ).format(DateTime.now().toUtc().add(const Duration(days: 0))),
        "08:00",
        1,
        0,
        0,
        0,
        0,
      );
      
      setState(() {
        _apiResponse = rtn.toString();
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Error: ${e.toString()}';
      });
    }
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
              'G2Rail API Sample',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Test G2Rail API functionality'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _actAPI,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Test G2Rail API'),
            ),
            const SizedBox(height: 30),
            const Text(
              'API Response:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: Text(
                    _apiResponse,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
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
