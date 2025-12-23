import 'package:sneakerx/src/models/cart_item.dart';

class Cart {
  final int cartId;
  final int userId;
  final List<CartItem> cartItems;

  Cart({
    required this.cartId,
    required this.userId,
    required this.cartItems,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartId: json['cartId'],
      userId: json['userId'],
      cartItems: (json['cartItems'] as List?)
        ?.map((cartItem) => CartItem.fromJson(cartItem))
        .toList() ?? []
    );
  }
}