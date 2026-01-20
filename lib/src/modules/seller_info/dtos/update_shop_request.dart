class UpdateShopRequest {
  final int shopId;
  final String shopName;
  final String shopDescription;
  final String? shopLogo;

  UpdateShopRequest({
    required this.shopId,
    required this.shopName,
    required this.shopDescription,
    this.shopLogo,
  });

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'shopDescription': shopDescription,
      'shopLogo': shopLogo
    };
  }
}