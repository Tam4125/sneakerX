class ShopBasicInfo {
  final int shopId;
  final String shopName;
  final String shopDescription;
  final String shopLogo;
  final double rating;
  final int followersCount;

  ShopBasicInfo({
    required this.shopId,
    required this.shopName,
    required this.shopDescription,
    required this.shopLogo,
    required this.rating,
    required this.followersCount
  });

  factory ShopBasicInfo.fromJson(Map<String, dynamic> json) {
    return ShopBasicInfo(
      shopId: json['shopId'],
      shopName: json['shopName'] ?? "",
      shopDescription: json['shopDescription'] ?? "",
      shopLogo: json['shopLogo'] ?? "",
      rating: json['rating'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
    );
  }



}