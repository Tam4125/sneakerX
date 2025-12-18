class ProductVariant {
  final int variantId;
  final String variantType;
  final String variantValue;
  final double price;
  final int stock;

  ProductVariant({
    required this.variantId,
    required this.variantType,
    required this.variantValue,
    required this.price,
    required this.stock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      variantId: json['variantId'],
      variantType: json['variantType'],
      variantValue: json['variantValue'],
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
    );
  }
}