class CartItemResponse {
  final int itemId;
  final int skuId;
  final int quantity;
  final int productId;
  final String productName;
  final String shopName;
  final int shopId;
  final String productImageUrl;
  final String skuCode;
  final String variantDescription;
  final double unitPrice;
  final double subTotal;
  final int currentStock;
  final bool available;

  CartItemResponse({
    required this.itemId,
    required this.skuId,
    required this.quantity,
    required this.productId,
    required this.productName,
    required this.shopName,
    required this.shopId,
    required this.productImageUrl,
    required this.skuCode,
    required this.variantDescription,
    required this.unitPrice,
    required this.subTotal,
    required this.currentStock,
    required this.available,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      itemId: json['itemId'] ?? 0,
      skuId: json['skuId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      productId: json['productId'] ?? 0,

      // Strings: Default to empty if null
      productName: json['productName'] ?? "Unknown Product",
      shopName: json['shopName'] ?? "Unknown Shop",
      shopId: json['shopId'] ?? 0,
      productImageUrl: json['productImageUrl'] ?? "",

      // Variant Info
      skuCode: json['skuCode'] ?? "",
      variantDescription: json['variantDescription'] ?? "",

      // Financials: Use 'num' to safely handle int/double mismatch from API
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,

      // Stock & Logic
      currentStock: json['currentStock'] ?? 0,
      available: json['available'] ?? false,
    );
  }
}