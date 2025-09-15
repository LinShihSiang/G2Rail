import 'package:flutter/material.dart';
import '../repos/product_repo.dart';
import '../services/price_formatter.dart';
import '../repos/models/product.dart';
import '../repos/models/product_group.dart';
import '../repos/germany_tours_repo.dart';
import 'product_schloss_neuschwanstein_page.dart';
import 'germany_products_page.dart';
import 'product_page.dart';

class HomePage extends StatefulWidget {
  final ProductRepo repo;
  const HomePage({super.key, required this.repo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<ProductGroup>> _future;
  final Map<String, bool> _expandedGroups = {
    'group_tickets': true,
    'group_international_packages': true,
  };

  @override
  void initState() {
    super.initState();
    _future = widget.repo.getGroupedProducts();
  }

  void _toggleGroup(String groupId) {
    setState(() {
      _expandedGroups[groupId] = !(_expandedGroups[groupId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DoDoMan Travel')),
      body: FutureBuilder<List<ProductGroup>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Failed to load products: ${snap.error}'));
          }
          final groups = snap.data ?? const [];
          if (groups.isEmpty) {
            return const Center(child: Text('No products available'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) => ProductGroupWidget(
              group: groups[i],
              isExpanded: _expandedGroups[groups[i].id] ?? true,
              onToggle: () => _toggleGroup(groups[i].id),
            ),
          );
        },
      ),
    );
  }
}

class ProductGroupWidget extends StatelessWidget {
  final ProductGroup group;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ProductGroupWidget({
    super.key,
    required this.group,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: group.products
                    .map((product) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProductCard(product: product),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final priceText = formatPrice(product.price, product.currency);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (product.id == 'prod_germany_products') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => GermanyProductsPage(
                  repo: GermanyToursRepo(),
                ),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductPage(product: product),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFE0E0E0),
                      child: Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                product.propaganda,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
              if (priceText.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 18),
                    Text(
                      priceText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}