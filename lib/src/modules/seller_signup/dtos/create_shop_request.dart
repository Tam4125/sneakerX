import 'dart:io';

class CreateShopRequest {
  final String shopName;
  final String shopDescription;
  final File? shopLogo;

  CreateShopRequest({
    required this.shopName,
    required this.shopDescription,
    this.shopLogo,
  });
}