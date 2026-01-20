import 'package:sneakerx/src/models/shops.dart';
import 'package:sneakerx/src/models/user.dart';

class ShopFollower {
  final int followerId;
  final User user;
  final Shop shop;
  final DateTime followedAt;

  ShopFollower({
    required this.followerId,
    required this.user,
    required this.shop,
    required this.followedAt
  });

  factory ShopFollower.fromJson(Map<String, dynamic> json) {
    return ShopFollower(
      followerId: json['followerId'],
      user: User.fromJson(json['user']),
      shop: Shop.fromJson(json['shop']),
      followedAt: json['followedAt']
    );
  }
}