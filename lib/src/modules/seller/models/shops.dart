// models/seller.dart
class Shop {
  int shopId;
  int userId;
  String shopName;
  String? shopDescription;
  int followersCount;
  double rating;
  String status; // 'active', 'hidden', 'banned
  String createdAt;
  String updatedAt;

  Shop({
    required this.shopId,
    required this.userId,
    required this.shopName,
    this.shopDescription,
    this.followersCount = 0,
    this.rating = 0.0,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });
}