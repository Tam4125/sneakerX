class ProductVariant {
  final int variantId;      // PK
  final int productId;      // FK
  final String variantType; // size, color...
  final String variantValue;// "37", "Red"...
  final double price;
  final int stock;

  ProductVariant({
    required this.variantId,
    required this.productId,
    required this.variantType,
    required this.variantValue,
    required this.price,
    required this.stock,
  });
}