import 'package:sneakerx/src/models/custom/address_snapshot.dart';
import 'package:sneakerx/src/models/enums/payment_status.dart';
import 'package:sneakerx/src/models/payment.dart';
import 'package:sneakerx/src/models/shop_order.dart';

class Order {
  final int orderId;
  final int userId;
  final List<Payment> payments;
  final AddressSnapshot shippingAddress;
  final double totalAmount;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final List<ShopOrder> shopOrders;

  Order({
    required this.orderId,
    required this.userId,
    required this.payments,
    required this.shippingAddress,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
    required this.shopOrders,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      userId: json['userId'],
      payments: (json['payments'] as List?)
        ?.map((ele) => Payment.fromJson(ele as Map<String, dynamic>))
        .toList() ?? [],
      shippingAddress: AddressSnapshot.fromJson(json['shippingAddress']),
      totalAmount: json['totalAmount'],
      paymentStatus: PaymentStatus.values.byName(json['paymentStatus']),
      createdAt: DateTime.parse(json['createdAt']),
      shopOrders: (json['shopOrders'] as List?)
        ?.map((ele) => ShopOrder.fromJson(ele as Map<String, dynamic>))
        .toList() ?? [],
    );
  }
}