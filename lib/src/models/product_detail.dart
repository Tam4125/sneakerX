// 2. Product Detail (Matches ProductDetailResponse)
import 'package:intl/intl.dart';
import 'package:sneakerx/src/models/product_image.dart';
import 'package:sneakerx/src/models/product_review.dart';
import 'package:sneakerx/src/models/product_variant.dart';

class ProductDetail {
  final int productId;
  final int shopId;
  final int categoryId;
  final String name;
  final String description;
  final double rating;
  final int soldCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final List<ProductReview> reviews;

  ProductDetail({
    required this.productId,
    required this.shopId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.rating,
    required this.soldCount,
    required this.images,
    required this.variants,
    required this.reviews,
    required this.createdAt,
    required this.updatedAt
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      productId: json['productId'],
      shopId: json['shopId'],
      categoryId: json['categoryId'] ?? 0,
      name: json['name'],
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      soldCount: json['soldCount'] ?? 0,
      images: (json['images'] as List?)
          ?.map((i) => ProductImage.fromJson(i))
          .toList() ?? [],
      variants: (json['variants'] as List?)
          ?.map((v) => ProductVariant.fromJson(v))
          .toList() ?? [],
      reviews: (json['reviews'] as List?)
          ?.map((v) => ProductReview.fromJson(v))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
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
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper to format currency
  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }
}