class Product {
  final String id;
  final String name;
  final String imageUrl;   // local asset or remote URL
  final String propaganda; // marketing tagline
  final num? price;        // numeric price, ex: 21, nullable for when price not set
  final String currency;   // ISO 4217, e.g., "EUR"

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.propaganda,
    this.price,              // now optional
    required this.currency,
  });
}