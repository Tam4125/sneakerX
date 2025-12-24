import 'package:sneakerx/src/models/product.dart';

class OrderItem {
  final int orderItemId;
  final int orderId;
  final Product product;
  final int sizeId;
  final int colorId;
  final int quantity;
  final double price;

  OrderItem({
    required this.orderItemId,
    required this.orderId,
    required this.product,
    required this.sizeId,
    required this.colorId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: json['orderItemId'],
      orderId: json['orderId'],
      product: Product.fromJson(json['product']),
      sizeId: json['sizeId'],
      colorId: json['colorId'],
      quantity: json['quantity'],
      price: json['price']
    );
  }
}