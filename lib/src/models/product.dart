import 'package:sneakerx/src/models/product_image.dart';

class Product {
  final int productId;
  final int categoryId;
  final int shopId;
  final String name;
  final String description;
  final double basePrice;
  final double rating;
  final int soldCount;
  final DateTime createdAt;

  final List<ProductImage> images;

  Product({
    required this.productId,
    required this.shopId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.rating,
    required this.soldCount,
    required this.images,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      shopId: json['shopId'],
      categoryId: json['categoryId'],
      name: json['name'],
      description: json['description'],
      basePrice: json['basePrice'],
      rating: json['rating'].toDouble(),
      soldCount: json['soldCount'],
      createdAt: DateTime.parse(json['createdAt']),
      images: (json['images'] as List?)
        ?.map((image) => ProductImage.fromJson(image as Map<String, dynamic>))
        .toList() ?? []
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'shopId': shopId,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'rating': rating,
      'status': "ACTIVE",
      'soldCount': soldCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}