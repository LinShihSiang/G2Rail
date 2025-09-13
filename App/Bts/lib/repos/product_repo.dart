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