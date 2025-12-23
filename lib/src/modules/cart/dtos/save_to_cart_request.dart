class SaveToCartRequest {
  final int sizeId;
  final int colorId;
  final int quantity;
  final int productId;

  SaveToCartRequest({
    required this.sizeId,
    required this.colorId,
    required this.quantity,
    required this.productId
  });

  Map<String, dynamic> toJson() {
    return {
      'sizeId': sizeId,
      'colorId': colorId,
      'quantity': quantity,
      'productId': productId
    };
  }

}