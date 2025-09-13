# Home Page — Step 1: Implementation Document

## Goal
List all travel products on the Home page using a scrollable list. Each item shows:
- One promo image
- Product tagline (propaganda)
- Price
- Currency

Initial catalog contains **Schloss Neuschwanstein**.

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

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.propaganda,
    required this.price,
    required this.currency,
  });
}
```

### Seed Data (MVP)
```dart
// lib/repos/product_repo.dart
import 'models/product.dart';

abstract class ProductRepo {
  Future<List<Product>> getAll();
}

class InMemoryProductRepo implements ProductRepo {
  @override
  Future<List<Product>> getAll() async {
    return const [
      Product(
        id: 'prod_schloss_neuschwanstein',
        name: 'Schloss Neuschwanstein',
        imageUrl: 'assets/images/schloss_neuschwanstein.jpg', // placeholder
        propaganda: '95折優惠，18歲以下免費同行',
        price: 21,
        currency: 'EUR',
      ),
    ];
  }
}
```

> **Image note:** Use a placeholder asset path for now (`assets/images/schloss_neuschwanstein.jpg`). You can later replace it with a generated or licensed photo. Add to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/schloss_neuschwanstein.jpg
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
- **HomePage** shows a `ListView.builder`.
- Each row is a **ProductCard**:
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

class HomePage extends StatefulWidget {
  final ProductRepo repo;
  const HomePage({super.key, required this.repo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repo.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: FutureBuilder<List<Product>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Failed to load products: ${snap.error}'));
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('No products available'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => ProductCard(product: items[i]),
          );
        },
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
      title: 'Travel Agency',
      home: HomePage(repo: repo),
      // routes for detail to be added in Step 2
    );
  }
}
```

---

## Acceptance Criteria (QA Checklist)
- [ ] Home page loads without crash and shows a spinner while loading.
- [ ] When the repo returns products, a list appears; empty repo → “No products available”.
- [ ] Each item displays image, **name**, **propaganda**, and **price with currency**.
- [ ] Price for `EUR` renders as `€21` for the sample product.
- [ ] Images have rounded corners and maintain 16:9 aspect ratio.
- [ ] Tap on a card prepares navigation (stub OK for Step 1).
- [ ] No visual overflow on narrow phones; text truncates gracefully.

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
    product_repo.dart
  services/
    price_formatter.dart
```

---

## Product Detail Setting (Source of Truth for Step 1)
- **Product:** Schloss Neuschwanstein  
  - **Image:** `assets/images/schloss_neuschwanstein.jpg` (placeholder; replace later)  
  - **Propaganda:** `95折優惠，18歲以下免費同行`  
  - **Price:** `21`  
  - **Currency:** `EUR`
