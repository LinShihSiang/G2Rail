class GermanyTourPackage {
  final String id;           // from _id
  final String name;         // package name
  final String intro;        // description
  final String priceEur;     // original price in EUR
  final double sellPrice;    // calculated sell price = (priceEur * 0.9 + 2) rounded to 2 decimal places
  final List<String> images; // image URLs
  final String location;     // Berlin or Munich

  const GermanyTourPackage({
    required this.id,
    required this.name,
    required this.intro,
    required this.priceEur,
    required this.sellPrice,
    required this.images,
    required this.location,
  });

  factory GermanyTourPackage.fromJson(Map<String, dynamic> json) {
    final priceEurString = json['price_eur']?.toString() ?? '0.0';
    final priceEurDouble = double.tryParse(priceEurString) ?? 0.0;
    
    // Calculate sell price = (priceEur * 0.9 + 2) rounded to 2 decimal places
    final calculatedPrice = (priceEurDouble * 0.9 + 2);
    final sellPrice = double.parse(calculatedPrice.toStringAsFixed(2));

    return GermanyTourPackage(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      intro: json['intro'] ?? '',
      priceEur: priceEurString,
      sellPrice: sellPrice,
      images: List<String>.from(json['images'] ?? []),
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'intro': intro,
      'price_eur': priceEur,
      'sell_price': sellPrice,
      'images': images,
      'location': location,
    };
  }

  @override
  String toString() {
    return 'GermanyTourPackage(id: $id, name: $name, location: $location, sellPrice: €${sellPrice.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GermanyTourPackage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}