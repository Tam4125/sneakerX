import 'package:flutter/material.dart';

class AppConfig {
  static const primary = Color(0xFF5ED696);      // Xanh lá (Mua ngay)
  static const secondary = Color(0xFF8E44AD);    // Tím (Giỏ hàng)
  static const flashSale = Color(0xFF65D498);
  static const background = Color(0xFFF5F5F5);   // Xám nhạt

  // Predefined Size Options
  final List<String> sizeOptions = [
    "36", "37", "38", "39", "40", "41", "42", "43", "44", "45"
  ];

  // Predefined Color Options (Hex -> Display Name)
  final Map<String, String> colorOptions = {
    "0xFFFF0000": "Đỏ",
    "0xFF0000FF": "Xanh Dương",
    "0xFFFFFF00": "Vàng",
    "0xFF000000": "Đen",
    "0xFF808080": "Xám",
    "0xFF8E44AD": "Tím",
    "0xFFFFFFFF": "Trắng",
  };

  static String getColorName(String hexCode) {
    switch (hexCode) {
      case "0xFFFF0000": return "Đỏ";
      case "0xFF0000FF": return "Xanh Dương";
      case "0xFFFFFF00": return "Vàng";
      case "0xFF000000": return "Đen";
      case "0xFF808080": return "Xám";
      case "0xFF8E44AD": return "Tím";
      default: return "Màu khác";
    }
  }
}