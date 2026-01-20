class CartItem {
  final int itemId;
  final int cartId;
  final int skuId;
  final int quantity;

  CartItem({
    required this.itemId,
    required this.cartId,
    required this.skuId,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['itemId'],
      cartId: json['cartId'],
      skuId: json['skuId'],
      quantity: json['quantity']
    );
  }
}