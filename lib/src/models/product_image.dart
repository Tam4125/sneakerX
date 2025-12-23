class ProductImage {
  final int imageId;
  final int productId;
  final String imageUrl;
  final int sortOrder;

  ProductImage({
    required this.imageId,
    required this.productId,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      imageId: json['imageId'] ?? 0,
      productId: json['productId'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'productId': productId,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
    };
  }
}