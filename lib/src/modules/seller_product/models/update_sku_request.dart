class UpdateSkuRequest {
  final int skuId;
  final double price;
  final int stock;

  UpdateSkuRequest({
    required this.skuId,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toJson() {
    return {
      'skuId': skuId,
      'price': price,
      'stock': stock,
    };
  }
}