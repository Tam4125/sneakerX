import 'package:sneakerx/src/models/attribute_value.dart';

class ProductSku {
  final int skuId;
  final int productId;
  final String skuCode;
  final double price;
  final int stock;
  final int soldCount;
  final List<AttributeValue> values;

  ProductSku({
    required this.skuId,
    required this.productId,
    required this.skuCode,
    required this.price,
    required this.stock,
    required this.soldCount,
    required this.values,
  });

  factory ProductSku.fromJson(Map<String, dynamic> json) {
    return ProductSku(
      skuId: json['skuId'],
      productId: json['productId'],
      skuCode: json['skuCode'],
      price: json['price'],
      stock: json['stock'],
      soldCount: json['soldCount'],
      values: (json['values'] as List?)
        ?.map((ele) => AttributeValue.fromJson(ele as Map<String, dynamic>))
        .toList() ?? []
    );
  }
}