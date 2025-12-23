import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/models/shop_follower.dart';

class ShopDetailedInfo {
  final int shopId;
  final int userId;
  final String shopName;
  final String shopDescription;
  final String shopLogo;
  final double rating;
  final int followersCount;
  final String provinceOrCity;
  final String district;
  final String ward;
  final String addressLine;
  final DateTime createdAt;
  final String phone;
  final String email;
  final List<ShopFollower> followers;
  final List<Product> products;

  ShopDetailedInfo({
    required this.shopId,
    required this.userId,
    required this.shopName,
    required this.shopDescription,
    required this.shopLogo,
    required this.rating,
    required this.followersCount,
    required this.provinceOrCity,
    required this.district,
    required this.ward,
    required this.addressLine,
    required this.createdAt,
    required this.phone,
    required this.email,
    required this.followers,
    required this.products,

  });
}