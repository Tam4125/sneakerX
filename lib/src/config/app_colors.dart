import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF5ED696);      // Xanh lá (Mua ngay)
  static const secondary = Color(0xFF8E44AD);    // Tím (Giỏ hàng)
  static const flashSale = Color(0xFF65D498);
  static const background = Color(0xFFF5F5F5);   // Xám nhạt

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