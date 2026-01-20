import 'package:sneakerx/src/models/attribute_value.dart';

class ProductAttribute {
  final int attributeId;
  final int productId;
  final String name;
  final List<AttributeValue> values;

  ProductAttribute({
    required this.attributeId,
    required this.productId,
    required this.name,
    required this.values,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      attributeId: json['attributeId'],
      productId: json['productId'],
      name: json['name'],
      values: (json['values'] as List?)
        ?.map((ele) => AttributeValue.fromJson(ele as Map<String, dynamic>))
        .toList() ?? []
    );
  }
}