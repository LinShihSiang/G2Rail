import 'package:flutter/material.dart';
import '../repos/germany_tours_repo.dart';
import '../repos/models/germany_tour_package.dart';
import '../widgets/germany_tour_card.dart';
import 'product_page.dart';

class GermanyProductsPage extends StatefulWidget {
  final GermanyToursRepo repo;

  const GermanyProductsPage({super.key, required this.repo});

  @override
  State<GermanyProductsPage> createState() => _GermanyProductsPageState();
}

class _GermanyProductsPageState extends State<GermanyProductsPage> {
  late Future<List<GermanyTourPackage>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repo.getGermanyTours();
  }

  void _navigateToTimetable(GermanyTourPackage tour) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductPage(package: tour),
      ),
    );
  }

  void _retry() {
    setState(() {
      _future = widget.repo.getGermanyTours();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Germany Popular Packages'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<GermanyTourPackage>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load tours',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final tours = snapshot.data ?? [];

          if (tours.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.tour_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Germany tour packages available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please check back later for new packages',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: tours.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tour = tours[index];
              return GermanyTourCard(
                tour: tour,
                onTap: () => _navigateToTimetable(tour),
              );
            },
          );
        },
      ),
    );
  }
}