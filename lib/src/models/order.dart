import 'package:sneakerx/src/models/enums/order_status.dart';
import 'package:sneakerx/src/models/order_item.dart';
import 'package:sneakerx/src/models/payment.dart';

class Order {
  final int orderId;
  final int userId;
  final int addressId;
  final double totalPrice;
  final double shippingFee;
  final OrderStatus orderStatus;
  final List<OrderItem> orderItems;
  final Payment payment;

  Order({
    required this.orderId,
    required this.userId,
    required this.addressId,
    required this.totalPrice,
    required this.shippingFee,
    required this.orderStatus,
    required this.orderItems,
    required this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      userId: json['userId'],
      addressId: json['addressId'],
      totalPrice: json['totalPrice'],
      shippingFee: json['shippingFee'],
      orderStatus: OrderStatus.values.byName(json['orderStatus']),
      orderItems: (json['orderItems'] as List?)
        ?.map((orderItem) => OrderItem.fromJson(orderItem)).toList()
        ?? [],
      payment: Payment.fromJson(json['payment'])
    );
  }
}