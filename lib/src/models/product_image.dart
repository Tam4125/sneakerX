class ProductImage {
  final int imageId;
  final int productId;
  final String imageUrl;

  ProductImage({required this.imageId, required this.imageUrl, required this.productId});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      imageId: json['imageId'],
      productId: json['productId'],
      imageUrl: json['imageUrl'],
    );
  }
}