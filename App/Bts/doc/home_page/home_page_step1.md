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

**New Features:**
- **Subscription Button**: Located in the top-right corner of the app bar
- **Subscription Dialog**: Popup dialog for user email and name input
- **Subscription API**: Call subscription service after user confirms

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

### Subscription Data Models
```dart
// lib/repos/models/subscription_request.dart
class SubscriptionRequest {
  final String email;
  final String name;

  const SubscriptionRequest({
    required this.email,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
    };
  }
}

// lib/repos/models/subscription_response.dart
class SubscriptionResponse {
  final bool success;
  final String message;

  const SubscriptionResponse({
    required this.success,
    required this.message,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
```

### Subscription Service
```dart
// lib/services/subscription_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../repos/models/subscription_request.dart';
import '../repos/models/subscription_response.dart';

class SubscriptionService {
  final String baseUrl;
  final http.Client httpClient;

  SubscriptionService({
    required this.baseUrl,
    required this.httpClient,
  });

  Future<SubscriptionResponse> subscribe(SubscriptionRequest request) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/subscribe'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SubscriptionResponse.fromJson(responseData);
      } else {
        return SubscriptionResponse(
          success: false,
          message: 'Subscription failed. Please try again later.',
        );
      }
    } catch (e) {
      return SubscriptionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
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
          Product(
            id: 'prod_uffizi_gallery',
            name: 'Uffizi Gallery Art',
            imageUrl: 'assets/images/uffizi_gallery_art.jpg',
            propaganda: '5% discount, free admission for companions under 18.',
            price: 35.9,
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

> **Image note:** Use placeholder asset paths for now (`assets/images/schloss_neuschwanstein.jpg`, `assets/images/uffizi_gallery_art.jpg`, and `assets/images/germany_products.jpg`). You can later replace them with generated or licensed photos. Add to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/schloss_neuschwanstein.jpg
    - assets/images/uffizi_gallery_art.jpg
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
import '../../services/subscription_service.dart';
import '../../repos/models/product.dart';
import '../../repos/models/product_group.dart';
import '../../repos/models/subscription_request.dart';

class HomePage extends StatefulWidget {
  final ProductRepo repo;
  final SubscriptionService subscriptionService;

  const HomePage({
    super.key,
    required this.repo,
    required this.subscriptionService,
  });

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

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => SubscriptionDialog(
        subscriptionService: widget.subscriptionService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DoDoMan Travel'),
        actions: [
          IconButton(
            onPressed: _showSubscriptionDialog,
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Subscribe to notifications',
          ),
        ],
      ),
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

class SubscriptionDialog extends StatefulWidget {
  final SubscriptionService subscriptionService;

  const SubscriptionDialog({
    super.key,
    required this.subscriptionService,
  });

  @override
  State<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  Future<void> _submitSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = SubscriptionRequest(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
      );

      final response = await widget.subscriptionService.subscribe(request);

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Subscribe to Notifications'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Get notified about our latest travel deals and packages!',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: _validateName,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitSubscription(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitSubscription,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Subscribe'),
        ),
      ],
    );
  }
}
```

---

## Routing (Prep for Step 2)
- Define named routes for `/` (Home) and `/product/:id` (later).
```dart
// lib/main.dart (snippet)
import 'package:http/http.dart' as http;
import 'repos/product_repo.dart';
import 'services/subscription_service.dart';
import 'pages/home/home_page.dart';

void main() {
  final repo = InMemoryProductRepo();
  final subscriptionService = SubscriptionService(
    baseUrl: 'https://api.dodoman-travel.com', // Replace with actual API endpoint
    httpClient: http.Client(),
  );
  runApp(MyApp(
    repo: repo,
    subscriptionService: subscriptionService,
  ));
}

class MyApp extends StatelessWidget {
  final ProductRepo repo;
  final SubscriptionService subscriptionService;

  const MyApp({
    super.key,
    required this.repo,
    required this.subscriptionService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoDoMan Travel',
      home: HomePage(
        repo: repo,
        subscriptionService: subscriptionService,
      ),
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
- [ ] Schloss Neuschwanstein and Uffizi Gallery Art appear under "Tickets" group.
- [ ] Germany Popular Packages appears under "International Packages" group.
- [ ] Each product displays image, **name**, **propaganda**, and **price with currency**.
- [ ] Price for `EUR` renders as `€21` for the sample product.
- [ ] Images have rounded corners and maintain 16:9 aspect ratio.
- [ ] Tap on a product card prepares navigation (stub OK for Step 1).
- [ ] No visual overflow on narrow phones; text truncates gracefully.
- [ ] Group expansion state persists during the session.

**Subscription Feature:**
- [ ] Subscription button (notification icon) appears in the top-right corner of app bar.
- [ ] Tapping subscription button opens subscription dialog popup.
- [ ] Dialog displays title "Subscribe to Notifications" and descriptive text.
- [ ] Dialog contains "Full Name" and "Email Address" input fields with validation.
- [ ] Name field validates minimum 2 characters and required input.
- [ ] Email field validates proper email format and required input.
- [ ] Dialog has "Cancel" and "Subscribe" buttons.
- [ ] Cancel button closes dialog without action.
- [ ] Subscribe button is disabled while loading and shows progress indicator.
- [ ] Form validation prevents submission with invalid data.
- [ ] Successful subscription shows green snackbar with success message.
- [ ] Failed subscription shows red snackbar with error message.
- [ ] Dialog closes automatically after successful subscription.
- [ ] Network errors are handled gracefully with user-friendly messages.

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
      subscription_request.dart
      subscription_response.dart
    product_repo.dart
  services/
    price_formatter.dart
    subscription_service.dart
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

- **Product 2:** Uffizi Gallery Art
  - **Category:** `tickets`
  - **Image:** `assets/images/uffizi_gallery_art.jpg` (應顯示烏菲茲美術館外觀建築)
  - **Propaganda:** `5% discount, free admission for companions under 18.`
  - **Price:** `35.9`
  - **Currency:** `EUR`
  - **描述:** 位於佛羅倫斯的著名烏菲茲美術館，收藏文藝復興時期藝術珍品

### Group 2: International Packages
- **Product 3:** Germany Popular Packages
  - **Category:** `packages`
  - **Image:** `assets/images/germany_products.jpg` (placeholder; replace later)
  - **Propaganda:** `Explore authentic German travel experiences`
  - **Price:** No specific price (will show as package collection)
  - **Currency:** `EUR`
