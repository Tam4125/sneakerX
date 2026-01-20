class Shop {
  final int shopId;
  final int userId;
  final String shopName;
  final String? shopDescription;
  final String shopLogo;
  final int followersCount;
  final double rating;
  final DateTime createdAt;


  Shop({
    required this.shopId,
    required this.shopName,
    required this.shopLogo,
    this.shopDescription,
    required this.followersCount,
    required this.rating,
    required this.createdAt,
    required this.userId,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shopId: json['shopId'],
      shopName: json['shopName'] ?? "",
      shopDescription: json['shopDescription'] ?? "",
      shopLogo: json['shopLogo'] ?? "",
      followersCount: json['followersCount'] ?? 0,
      rating: json['rating'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
    );
  }
}