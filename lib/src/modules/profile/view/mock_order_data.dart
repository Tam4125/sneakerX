import 'package:flutter/material.dart';

enum OrderStatus {
  waitConfirm, // Chờ xác nhận
  waitPickup,  // Chờ lấy hàng
  shipping,    // Chờ giao hàng
  delivered,   // Đã giao
  cancelled    // Đã hủy
}

class OrderModel {
  final String id;
  final String shopName;
  final String productName;
  final String productImage;
  final String variant;
  final double price;
  final int quantity;
  final double totalAmount;
  final OrderStatus status;

  OrderModel({
    required this.id,
    required this.shopName,
    required this.productName,
    required this.productImage,
    required this.variant,
    required this.price,
    required this.quantity,
    required this.totalAmount,
    required this.status,
  });

  String get formattedPrice => "${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";
  String get formattedTotal => "${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";
}

class MockOrderData {
  static final List<OrderModel> orders = [
    // --- 1. ĐƠN CHỜ LẤY HÀNG ---
    OrderModel(
      id: "ORD002",
      shopName: "Adidas Flagship",
      productName: "Giày Chạy Bộ Adidas UltraBoost 22",
      productImage: "assets/images/ngoc.jpg", // Đảm bảo đường dẫn ảnh đúng
      variant: "Size 40, Xám",
      price: 2500000,
      quantity: 1,
      totalAmount: 2500000,
      status: OrderStatus.waitPickup,
    ),

    // --- 2. ĐƠN ĐANG GIAO ---
    OrderModel(
      id: "ORD003",
      shopName: "Puma Store VN",
      productName: "Puma Suede Classic XXI",
      productImage: "assets/images/ngoc.jpg",
      variant: "Size 41, Đỏ",
      price: 1800000,
      quantity: 1,
      totalAmount: 1800000,
      status: OrderStatus.shipping,
    ),

    // --- 3. ĐƠN ĐÃ GIAO ---
    OrderModel(
      id: "ORD004",
      shopName: "Nike Official Shop",
      productName: "Nike Air Force 1 Pro",
      productImage: "assets/images/ngoc.jpg",
      variant: "Size 43, Xanh Navy",
      price: 1500000,
      quantity: 2,
      totalAmount: 3000000,
      status: OrderStatus.delivered,
    ),
  ];

  static List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }
}