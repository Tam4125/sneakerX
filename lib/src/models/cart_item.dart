import 'package:sneakerx/src/models/product.dart';

class CartItem {
  final int itemId;
  final Product product;
  final int sizeId;
  final int colorId;
  final int quantity;

  CartItem({
    required this.itemId,
    required this.product,
    required this.sizeId,
    required this.colorId,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['itemId'],
      product: Product.fromJson(json['product']),
      sizeId: json['sizeId'],
      colorId: json['colorId'],
      quantity: json['quantity']
    );
  }
}