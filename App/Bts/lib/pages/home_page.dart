import 'package:flutter/material.dart';
import 'package:g2railsample/pages/product_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Sample travel products data
  final List<Map<String, dynamic>> _travelProducts = const [
    {
      'id': 'neuschwanstein',
      'title': 'Schloss Neuschwanstein',
      'description': 'Visit the famous fairy-tale castle in Bavaria',
      'price': 89.99,
      'image': 'assets/neuschwanstein.jpg', // TODO: Add actual assets
      'duration': '1 Day',
      'includes': ['Transportation', 'Castle Tour', 'Guide'],
    },
    {
      'id': 'rhine_valley',
      'title': 'Rhine Valley Tour',
      'description': 'Scenic train journey through the Rhine Valley',
      'price': 129.99,
      'image': 'assets/rhine.jpg', // TODO: Add actual assets
      'duration': '2 Days',
      'includes': ['Train Travel', 'Hotel', 'Meals'],
    },
    {
      'id': 'black_forest',
      'title': 'Black Forest Adventure',
      'description': 'Explore the mystical Black Forest region',
      'price': 159.99,
      'image': 'assets/black_forest.jpg', // TODO: Add actual assets
      'duration': '3 Days',
      'includes': ['Transportation', 'Accommodation', 'Activities'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('G2Rail Travel'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover Amazing',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Travel Experiences',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Book your perfect European adventure',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Popular Travel Packages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _travelProducts.length,
              itemBuilder: (context, index) {
                final product = _travelProducts[index];
                return _buildProductCard(context, product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToProduct(context, product),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey[300],
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        product['duration'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${product['price'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProduct(BuildContext context, Map<String, dynamic> product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductPage(product: product),
      ),
    );
  }
}