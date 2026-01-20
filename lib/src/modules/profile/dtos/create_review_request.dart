class CreateReviewRequest {
  final int userId;
  final List<int> productIds;
  final Map<int, double> ratingMap;
  final Map<int, String> commentMap;

  CreateReviewRequest({
    required this.userId,
    required this.productIds,
    required this.ratingMap,
    required this.commentMap,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productIds': productIds,
      'ratingMap': ratingMap.map((key, value) => MapEntry(key.toString(), value)),
      'commentMap': commentMap.map((key, value) => MapEntry(key.toString(), value)),
    };
  }
}