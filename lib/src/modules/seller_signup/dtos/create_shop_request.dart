class CreateShopRequest {
  final String shopName;
  final String shopDescription;
  final String? shopLogo;

  CreateShopRequest({
    required this.shopName,
    required this.shopDescription,
    this.shopLogo,
  });

  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'shopDescription': shopDescription,
      'shopLogo': shopLogo,
    };
  }
}