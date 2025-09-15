# Home Page — Step 1: Implementation Document

## Goal
Display DoDoMan Travel products on the Home page using a grouped, expandable/collapsible structure. Each product item shows:
- One promo image
- Product tagline (propaganda)
- Price
- Currency

Products are organized into two main groups:
1. **Tickets** - Contains individual attraction tickets (e.g., Schloss Neuschwanstein)
2. **International Packages** - Contains travel package collections (e.g., Germany Popular Packages)

Each group can be expanded or collapsed to show/hide its contents.

---

## Data Model

```dart
// lib/repos/models/product.dart
class Product {
  final String id;
  final String name;
  final String imageUrl;   // local asset or remote URL
  final String propaganda; // marketing tagline
  final num price;         // numeric price, ex: 21
  final String currency;   // ISO 4217, e.g., "EUR"
  final String category;   // Product category: "tickets" or "packages"

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.propaganda,
    required this.price,
    required this.currency,
    required this.category,
  });
}

// lib/repos/models/product_group.dart
class ProductGroup {
  final String id;
  final String name;
  final String category;   // "tickets" or "packages"
  final List<Product> products;
  final bool isExpanded;

  const ProductGroup({
    required this.id,
    required this.name,
    required this.category,
    required this.products,
    this.isExpanded = true,
  });
}
```

### Seed Data (MVP)
```dart
// lib/repos/product_repo.dart
import 'models/product.dart';
import 'models/product_group.dart';

abstract class ProductRepo {
  Future<List<ProductGroup>> getGroupedProducts();
}

class InMemoryProductRepo implements ProductRepo {
  @override
  Future<List<ProductGroup>> getGroupedProducts() async {
    return const [
      ProductGroup(
        id: 'group_tickets',
        name: 'Tickets',
        category: 'tickets',
        isExpanded: true,
        products: [
          Product(
            id: 'prod_schloss_neuschwanstein',
            name: 'Schloss Neuschwanstein',
            imageUrl: 'assets/images/schloss_neuschwanstein.jpg',
            propaganda: '5% discount, free admission for companions under 18.',
            price: 21,
            currency: 'EUR',
            category: 'tickets',
          ),
        ],
      ),
      ProductGroup(
        id: 'group_international_packages',
        name: 'International Packages',
        category: 'packages',
        isExpanded: true,
        products: [
          Product(
            id: 'prod_germany_products',
            name: 'Germany Popular Packages',
            imageUrl: 'assets/images/germany_products.jpg',
            propaganda: 'Explore authentic German travel experiences',
            currency: 'EUR',
            category: 'packages',
          ),
        ],
      ),
    ];
  }
}
```

> **Image note:** Use placeholder asset paths for now (`assets/images/schloss_neuschwanstein.jpg` and `assets/images/germany_products.jpg`). You can later replace them with generated or licensed photos. Add to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/schloss_neuschwanstein.jpg
    - assets/images/germany_products.jpg
```

---

## Currency & Price Display
- Use `intl` package to format by currency code.
- EUR example: display as **€21** (no decimals for whole numbers).

```dart
// lib/services/price_formatter.dart
import 'package:intl/intl.dart';

String formatPrice(num amount, String currency) {
  final f = NumberFormat.simpleCurrency(name: currency);
  return f.format(amount);
}
```

Add dependency:
```yaml
dependencies:
  intl: ^0.19.0
```

---

## UI/UX

### Layout
- **DoDoMan Travel HomePage** shows grouped, expandable/collapsible sections.
- Two main groups: **Tickets** and **International Packages**
- Each group has a header with:
  - Group name (bold, larger text)
  - Expand/collapse icon (chevron up/down)
  - Tap to toggle expansion state
- When expanded, shows **ProductCard** list for that group:
  - Top: image (16:9, `ClipRRect` with rounded corners)
  - Below: name (bold), propaganda (secondary text, max 2 lines, ellipsis)
  - Right or bottom-right: formatted price

### Widgets
```dart
// lib/pages/home/home_page.dart
import 'package:flutter/material.dart';
import '../../repos/product_repo.dart';
import '../../services/price_formatter.dart';
import '../../repos/models/product.dart';
import '../../repos/models/product_group.dart';

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
          // TODO: Navigate to Product Detail (Step 2)
          // Navigator.pushNamed(context, '/product', arguments: product.id);
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
```

---

## Routing (Prep for Step 2)
- Define named routes for `/` (Home) and `/product/:id` (later).
```dart
// lib/main.dart (snippet)
import 'repos/product_repo.dart';
import 'pages/home/home_page.dart';

void main() {
  final repo = InMemoryProductRepo();
  runApp(MyApp(repo: repo));
}

class MyApp extends StatelessWidget {
  final ProductRepo repo;
  const MyApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoDoMan Travel',
      home: HomePage(repo: repo),
      // routes for detail to be added in Step 2
    );
  }
}
```

---

## Acceptance Criteria (QA Checklist)
- [ ] DoDoMan Travel home page loads without crash and shows a spinner while loading.
- [ ] Two main groups are displayed: "Tickets" and "International Packages".
- [ ] Each group header shows group name and expand/collapse chevron icon.
- [ ] Tapping group header toggles expansion state (chevron animates up/down).
- [ ] When expanded, products within that group are visible.
- [ ] When collapsed, products are hidden.
- [ ] Schloss Neuschwanstein appears under "Tickets" group.
- [ ] Germany Popular Packages appears under "International Packages" group.
- [ ] Each product displays image, **name**, **propaganda**, and **price with currency**.
- [ ] Price for `EUR` renders as `€21` for the sample product.
- [ ] Images have rounded corners and maintain 16:9 aspect ratio.
- [ ] Tap on a product card prepares navigation (stub OK for Step 1).
- [ ] No visual overflow on narrow phones; text truncates gracefully.
- [ ] Group expansion state persists during the session.

---

## Accessibility & i18n
- Use meaningful text hierarchy (title vs body).
- Ensure sufficient color contrast and tap target sizes.
- Prepare for localization of propaganda and currency (already supported via `intl`).

---

## Folder Placement (Project Structure Compliance)
```
lib/
  pages/
    home/
      home_page.dart
  repos/
    models/
      product.dart
      product_group.dart
    product_repo.dart
  services/
    price_formatter.dart
```

---

## Product Groups and Detail Setting (Source of Truth for Step 1)

### Group 1: Tickets
- **Product 1:** Schloss Neuschwanstein
  - **Category:** `tickets`
  - **Image:** `assets/images/schloss_neuschwanstein.jpg` (placeholder; replace later)
  - **Propaganda:** `5% discount, free admission for companions under 18.`
  - **Price:** `21`
  - **Currency:** `EUR`

### Group 2: International Packages
- **Product 2:** Germany Popular Packages
  - **Category:** `packages`
  - **Image:** `assets/images/germany_products.jpg` (placeholder; replace later)
  - **Propaganda:** `Explore authentic German travel experiences`
  - **Price:** No specific price (will show as package collection)
  - **Currency:** `EUR`
