class Product {
  final int id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });
}