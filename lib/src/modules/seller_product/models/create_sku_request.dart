class CreateSkuRequest {
  final String skuCode;
  final double price;
  final int stock;
  Map<String, String> specifications;

  CreateSkuRequest({
    required this.skuCode,
    required this.price,
    required this.stock,
    required this.specifications,
  });

  Map<String, dynamic> toJson() {
    return {
      'skuCode': skuCode,
      'price': price,
      'stock': stock,
      'specifications': specifications,
    };
  }
}