class GermanyTourPackage {
  final String id;           // from _id
  final String name;         // package name
  final String intro;        // description
  final String priceEur;     // price in EUR
  final List<String> images; // image URLs
  final String location;     // Berlin or Munich

  const GermanyTourPackage({
    required this.id,
    required this.name,
    required this.intro,
    required this.priceEur,
    required this.images,
    required this.location,
  });

  factory GermanyTourPackage.fromJson(Map<String, dynamic> json) {
    return GermanyTourPackage(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      intro: json['intro'] ?? '',
      priceEur: json['price_eur']?.toString() ?? '0.0',
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
      'images': images,
      'location': location,
    };
  }
}