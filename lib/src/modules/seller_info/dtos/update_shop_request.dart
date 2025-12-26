import 'dart:io';

class UpdateShopRequest {
  final int shopId;
  final String shopName;
  final String shopDescription;
  final File? shopLogo;

  UpdateShopRequest({
    required this.shopId,
    required this.shopName,
    required this.shopDescription,
    this.shopLogo,
  });
}