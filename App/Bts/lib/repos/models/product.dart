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