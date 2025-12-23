import 'package:sneakerx/src/models/product_variant.dart';

class SellerOrder {
  final String orderStatus;
  final int totalPrice;
  final int shippingFee;
  final int orderId;
  final int userId;
  final int productId;
  final int categoryId;
  final int? shopId;
  final String name;
  final String image;
  final List<ProductVariant>? variants;
  final DateTime createdAt;
  final int amount;
  final String provider;


  SellerOrder({
    required this.orderStatus,
    required this.totalPrice,
    this.shippingFee = 0,
    required this.userId,
    required this.orderId,
    required this.productId,
    required this.name,
    this.shopId,
    this.categoryId = 0,
    this.variants,
    required this.createdAt,
    required this.provider,
    this.amount = 0,
    this.image = '',
  });
}



