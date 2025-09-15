import 'models/product.dart';
import 'models/product_group.dart';

abstract class ProductRepo {
  Future<List<Product>> getAll();
  Future<List<ProductGroup>> getGroupedProducts();
}

class InMemoryProductRepo implements ProductRepo {
  @override
  Future<List<Product>> getAll() async {
    return const [
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
      Product(
        id: 'prod_germany_products',
        name: 'Germany Popular Packages',
        imageUrl: 'assets/images/germany_products.jpg',
        propaganda: 'Explore authentic German travel experiences',
        currency: 'EUR',
        category: 'packages',
      ),
    ];
  }

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