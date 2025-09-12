import 'dart:io';

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
          children: <Widget>[const Text('You have pushed the button')],
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
