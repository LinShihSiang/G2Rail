import 'package:flutter/material.dart';
import 'pages/germany_products_page.dart';
import 'repos/germany_tours_repo.dart';

/// Example demonstrating how to integrate the Germany Products Page
/// This is a standalone example that can be used as a reference
class GermanyIntegrationExample extends StatelessWidget {
  const GermanyIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Germany Tours Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GermanyDemoHome(),
    );
  }
}

class GermanyDemoHome extends StatelessWidget {
  const GermanyDemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = GermanyToursRepo();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Germany Tours Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Germany Tours Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GermanyProductsPage(repo: repo),
                  ),
                );
              },
              icon: const Icon(Icons.tour),
              label: const Text('View Germany Best-Selling Tickets'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'This demo shows Germany tour packages filtered from the '
                'Italy_Germany_tours.json data file. Tours are displayed '
                'for Berlin and Munich destinations.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}