import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/models/shop_follower.dart';
import 'package:sneakerx/src/models/shop_order.dart';
import 'package:sneakerx/src/models/shops.dart';

class ShopDetailResponse {
  final Shop shop;
  final List<ShopOrder> shopOrders;
  final List<Product> products;
  final List<ShopFollower> followers;
  
  ShopDetailResponse({
    required this.shop,  
    required this.shopOrders,
    required this.products,
    required this.followers,
  });
  
  factory ShopDetailResponse.fromJson(Map<String, dynamic> json) {
    return ShopDetailResponse(
      shop: Shop.fromJson(json['shop']),
      shopOrders: (json['shopOrders'] as List?)
        ?.map((ele) => ShopOrder.fromJson(ele as Map<String, dynamic>))
        .toList() ?? [],
      products: (json['products'] as List?)
          ?.map((ele) => Product.fromJson(ele as Map<String, dynamic>))
          .toList() ?? [],
      followers: (json['followers'] as List?)
          ?.map((ele) => ShopFollower.fromJson(ele as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}