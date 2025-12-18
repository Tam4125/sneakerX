import 'package:flutter/material.dart';

// 1. Voucher
class VoucherModel {
  final String id;
  final String title;
  final String subtitle;
  final double discountValue;
  final double minOrderValue;
  final bool isFreeShip;

  VoucherModel({
    required this.id, required this.title, required this.subtitle,
    required this.discountValue, required this.minOrderValue, this.isFreeShip = false,
  });
}

// 2. Thanh toán
class PaymentMethod {
  final String id;
  final String name;
  final IconData iconData;
  final bool isBankTransfer;

  PaymentMethod({
    required this.id, required this.name, required this.iconData, this.isBankTransfer = false,
  });
}

// 3. Ngân hàng (Cần cái này để hết lỗi BankModel)
class BankModel {
  final String id;
  final String name;
  final String shortName;
  final String logoUrl;

  BankModel({required this.id, required this.name, required this.shortName, required this.logoUrl});
}

// 4. Vận chuyển (Cần cái này để hết lỗi ShippingMethod)
class ShippingMethod {
  final String id;
  final String name;
  final String estimateTime;
  final double price;

  ShippingMethod({required this.id, required this.name, required this.estimateTime, required this.price});
}