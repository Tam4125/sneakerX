class ProductImage {
  final int imageId;
  final String imageUrl;

  ProductImage({required this.imageId, required this.imageUrl});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      imageId: json['imageId'],
      imageUrl: json['imageUrl'],
    );
  }
}