class Product {
  final String id;
  final String name;
  final String imageUrl;   // local asset or remote URL
  final String propaganda; // marketing tagline
  final num? price;        // numeric price, ex: 21, nullable for when price not set
  final String currency;   // ISO 4217, e.g., "EUR"
  final String category;   // Product category: "tickets" or "packages"

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.propaganda,
    this.price,              // now optional
    required this.currency,
    required this.category,
  });

  // Factory constructor for JSON serialization
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      propaganda: json['propaganda'] as String,
      price: json['price'] as num?,
      currency: json['currency'] as String,
      category: json['category'] as String,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'propaganda': propaganda,
      'price': price,
      'currency': currency,
      'category': category,
    };
  }
}