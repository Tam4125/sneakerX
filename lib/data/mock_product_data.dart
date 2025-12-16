class Product {
  final String name;
  final String image;
  final String description;
  final String price;
  final String sold;

  Product({
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    required this.sold,
  });
}

class MockProductData {
  static final List<Product> products = [
    Product(
      name: 'Naruto Plushie',
      image: 'assets/narutoplushie.jpg',
      description: 'Soft boi',
      price: '250.000đ',
      sold: '120',
    ),
    Product(
      name: 'Sasuke Plushie',
      image: 'assets/sasuke.jpg',
      description: 'Edgy boi',
      price: '260.000đ',
      sold: '98',
    ),
    Product(
      name: 'Sakura Plushie',
      image: 'assets/sasuke.jpg',
      description: 'Edgy boi',
      price: '6.000đ',
      sold: '1',
    ),
    Product(
      name: 'Might Guy Plushie',
      image: 'assets/sasuke.jpg',
      description: 'Edgy boi',
      price: '800.000đ',
      sold: '988',
    ),
    Product(
      name: 'Tsunade Plushie',
      image: 'assets/sasuke.jpg',
      description: 'Edgy boi',
      price: '660.000đ',
      sold: '98',
    ),
    Product(
      name: 'Bayonetta Plushie',
      image: 'assets/sasuke.jpg',
      description: 'Edgy boi',
      price: '660.000đ',
      sold: '98',
    ),
    Product(
      name: 'Gaara Plushie',
      image: 'assets/sasuke.jpg',
      description: 'Edgy boi',
      price: '660.000đ',
      sold: '98',
    ),
    Product(
      name: 'CR7 Plushie',
      image: 'assets/sasuke.jpg',
      description: 'Edgy boi',
      price: '660.000đ',
      sold: '98',
    ),
  ];
}