class SaveToCartRequest {
  final int quantity;
  final int skuId;

  SaveToCartRequest({
    required this.quantity,
    required this.skuId,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'skuId': skuId,
    };
  }

}