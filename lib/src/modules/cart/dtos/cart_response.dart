import 'package:sneakerx/src/modules/cart/dtos/cart_item_response.dart';

class CartResponse {
  final int cartId;
  final int userId;
  final List<CartItemResponse> cartItems;

  CartResponse({
    required this.cartId,
    required this.userId,
    required this.cartItems,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      cartId: json['cartId'] ?? 0,
      userId: json['userId'] ?? 0,
      // Safely map the list, returning empty list if null
      cartItems: (json['cartItems'] as List<dynamic>?)
          ?.map((item) => CartItemResponse.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}