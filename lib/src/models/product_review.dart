import 'package:sneakerx/src/models/user.dart';

class ProductReview {
  final int reviewId;
  final double rating;
  final String comment;
  final int userId;

  ProductReview({
    required this.reviewId,
    required this.rating,
    required this.comment,
    required this.userId,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      reviewId: json['reviewId'],
      rating: json['rating'],
      comment: json['comment'],
      userId: json['userId'],
    );
  }
}