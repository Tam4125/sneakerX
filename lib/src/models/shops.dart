import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/models/shop_follower.dart';

class Shop {
  final int shopId;
  final int userId;
  final String shopName;
  final String? shopDescription;
  final String shopLogo;
  final int followersCount;
  final double rating;
  final DateTime createdAt;
  final List<ShopFollower> followers;
  final List<Product> products;


  Shop({
    required this.shopId,
    required this.shopName,
    required this.shopLogo,
    this.shopDescription,
    required this.followersCount,
    required this.rating,
    required this.createdAt,
    required this.userId,
    required this.followers,
    required this.products
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
      followers: (json['followers'] as List?)
        ?.map((v) => ShopFollower.fromJson(v))
        .toList() ?? [],
      products: (json['products'] as List?)
          ?.map((v) => Product.fromJson(v))
          .toList() ?? [],
    );
  }
}