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
class PaymentMethodModel {
  final String id;
  final String name;
  final IconData iconData;
  final bool isBankTransfer;
  // Add this field to store the Stripe Transaction ID after payment
  String? transactionId;

  PaymentMethodModel({
    required this.id, required this.name, required this.iconData, this.isBankTransfer = false,this.transactionId});
}


class BankModel {
  final String id;
  final String name;
  final String shortName;
  final String logoUrl;

  BankModel({required this.id, required this.name, required this.shortName, required this.logoUrl});
}

class ShippingMethod {
  final String id;
  final String name;
  final String estimateTime;
  final double price;

  ShippingMethod({required this.id, required this.name, required this.estimateTime, required this.price});
}

class CheckoutData {
  // Shipping Options (IDs match your Enum)
  static final List<ShippingMethod> shippingOptions = [
    ShippingMethod(
        id: 'STANDARD',
        name: "Standard Delivery",
        estimateTime: "3-5 days",
        price: 5
    ),
    ShippingMethod(
        id: 'EXPEDITED',
        name: "Fast Delivery",
        estimateTime: "1-3 days",
        price: 10
    ),
    ShippingMethod(
        id: 'EXPRESS',
        name: "Express (2H)",
        estimateTime: "30 mins - 2 hours",
        price: 15
    ),
  ];

  static final List<PaymentMethodModel> paymentMethods = [
    PaymentMethodModel(
        id: 'COD', // Matches PaymentMethod.COD
        name: "Cash on Delivery (COD)",
        iconData: Icons.money
    ),
    PaymentMethodModel(
        id: 'STRIPE', // Matches PaymentMethod.STRIPE
        name: "Credit/Debit Card (Stripe)",
        iconData: Icons.credit_card
    ),
    PaymentMethodModel(
        id: 'BANKING', // Matches PaymentMethod.BANKING
        name: "Bank Transfer",
        iconData: Icons.account_balance,
        isBankTransfer: true
    ),
    // You can add MOMO, ZALOPAY, VNPAY here if implemented
  ];

  // 2. Bank List (Sample data for Bank Transfer flow)
  static final List<BankModel> banks = [
    BankModel(id: 'VCB', name: "Vietcombank", shortName: "VCB", logoUrl: "https://img.mservice.io/momo_app_v2/img/Vietcombank.png"),
    BankModel(id: 'MB', name: "MB Bank", shortName: "MB", logoUrl: "https://img.mservice.io/momo_app_v2/img/MBBank.png"),
    BankModel(id: 'TCB', name: "Techcombank", shortName: "TCB", logoUrl: "https://img.mservice.io/momo_app_v2/img/Techcombank.png"),
    BankModel(id: 'ACB', name: "Asia Commercial Bank", shortName: "ACB", logoUrl: "https://img.mservice.io/momo_app_v2/img/ACB.png"),
  ];
}