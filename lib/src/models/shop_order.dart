import 'package:sneakerx/src/models/enums/order_status.dart';
import 'package:sneakerx/src/models/order_item.dart';
import 'package:sneakerx/src/models/shops.dart';

class ShopOrder {
  final int shopOrderId;
  final int orderId;
  final Shop shop;
  final double shippingFee;
  final double subTotal;
  final OrderStatus orderStatus;
  final String noteToSeller;
  final DateTime createdAt;
  final List<OrderItem> orderItems;

  ShopOrder({
    required this.shopOrderId,
    required this.orderId,
    required this.shop,
    required this.shippingFee,
    required this.subTotal,
    required this.orderStatus,
    required this.noteToSeller,
    required this.createdAt,
    required this.orderItems,
  });
  
  factory ShopOrder.fromJson(Map<String, dynamic> json) {
    return ShopOrder(
      shopOrderId: json['shopOrderId'],
      orderId: json['orderId'],
      shop: Shop.fromJson(json['shop'] as Map<String, dynamic>),
      shippingFee: json['shippingFee'],
      subTotal: json['subTotal'],
      orderStatus: OrderStatus.values.byName(json['orderStatus']),
      noteToSeller: json['noteToSeller'],
      createdAt: DateTime.parse(json['createdAt']),
      orderItems: (json['orderItems'] as List?)
        ?.map((ele) => OrderItem.fromJson(ele as Map<String, dynamic>))
        .toList() ?? []
    );
  }
  
}