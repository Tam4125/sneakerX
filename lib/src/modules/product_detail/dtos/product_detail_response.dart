import 'package:sneakerx/src/models/category.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/models/product_attribute.dart';
import 'package:sneakerx/src/models/product_review.dart';
import 'package:sneakerx/src/models/product_sku.dart';
import 'package:sneakerx/src/models/shops.dart';

class ProductDetailResponse {
  final Product product;
  final ProductCategory category;
  final Shop shop;
  final List<ProductAttribute> attributes;
  final List<ProductSku> skus;
  final List<ProductReview> reviews;

  ProductDetailResponse({
    required this.product,
    required this.category,
    required this.shop,
    required this.attributes,
    required this.skus,
    required this.reviews,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      category: ProductCategory.fromJson(json['category'] as Map<String, dynamic>),
      shop: Shop.fromJson(json['shop'] as Map<String, dynamic>),
      attributes: (json['attributes'] as List?)
        ?.map((ele) => ProductAttribute.fromJson(ele as Map<String, dynamic>))
        .toList() ?? [],
      skus: (json['skus'] as List?)
          ?.map((ele) => ProductSku.fromJson(ele as Map<String, dynamic>))
          .toList() ?? [],
      reviews: (json['reviews'] as List?)
          ?.map((ele) => ProductReview.fromJson(ele as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}