import 'product.dart';

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

  // Create a copy with updated expansion state
  ProductGroup copyWith({
    String? id,
    String? name,
    String? category,
    List<Product>? products,
    bool? isExpanded,
  }) {
    return ProductGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      products: products ?? this.products,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  // Factory constructor for JSON serialization
  factory ProductGroup.fromJson(Map<String, dynamic> json) {
    return ProductGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      products: (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      isExpanded: json['isExpanded'] as bool? ?? true,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'products': products.map((e) => e.toJson()).toList(),
      'isExpanded': isExpanded,
    };
  }
}
