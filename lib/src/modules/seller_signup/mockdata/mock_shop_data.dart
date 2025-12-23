import 'package:flutter/material.dart';
import 'package:sneakerx/src/modules/seller_info/models/shop_detailed_info.dart';

class MockShopData {
  static List<ShopDetailedInfo> GetShopData() {
    return [
      ShopDetailedInfo(
      shopId: 1,
      userId: 1,
      shopName: 'EATITUPTOYSTORE',
      shopDescription: 'EATITUPTOYSTORE mang đến hàng loại lựa chọn tuyệt vời cho những món quà cho tất cả mọi người. Từ đồ chơi con nít đến đồ chơi người lớn (cụ thể là lego, chứ m nghĩ gì???? 🤔)',
      shopLogo: 'assets/images/sellerpic.jpg',
      followersCount: 6707,
      rating: 4.67,
      createdAt: DateTime.now(),
      followers: [],
      products: [],
      provinceOrCity: 'Thành Phố Hồ Chí Minh',
      district: 'Quận 3',
      ward: 'Phường 14',
      addressLine: '108/38L',
      phone: '0919206506',
      email: 'yophonelinging@gmail.com',
      ),
    ];
  }
}