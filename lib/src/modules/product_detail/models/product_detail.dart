// 2. Product Detail (Matches ProductDetailResponse)
import 'package:intl/intl.dart';
import 'package:sneakerx/src/modules/product_detail/models/product_image.dart';
import 'package:sneakerx/src/modules/product_detail/models/product_variant.dart';

class ProductDetail {
  final int productId;
  final String name;
  final String description;
  final double rating;
  final int soldCount;
  final List<ProductImage> images;
  final List<ProductVariant> variants;

  ProductDetail({
    required this.productId,
    required this.name,
    required this.description,
    required this.rating,
    required this.soldCount,
    required this.images,
    required this.variants,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      productId: json['productId'],
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
    );
  }

  // Helper to format currency
  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }
}