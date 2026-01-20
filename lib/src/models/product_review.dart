class ProductReview {
  final int reviewId;
  final int productId;
  final double rating;
  final String comment;
  final int userId;
  final DateTime createdAt;

  ProductReview({
    required this.reviewId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.userId,
    required this.createdAt
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      reviewId: json['reviewId'],
      productId: json['productId'],
      rating: json['rating'],
      comment: json['comment'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}