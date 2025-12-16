class ProductImage {
  final int imageId;    // PK
  final int productId;  // FK
  final String imageUrl;
  final int sortOrder;

  ProductImage({
    required this.imageId,
    required this.productId,
    required this.imageUrl,
    required this.sortOrder,
  });
}