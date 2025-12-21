import 'package:shared_preferences/shared_preferences.dart';

class UserInfoManager {
  static const String _shopId = 'shopId';

  // Save
  static Future<void> saveShopId(int shopId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_shopId, shopId);
  }

  // Get ShopId
  static Future<int?> getShopId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_shopId);
  }


  // Clear (Logout)
  static Future<void> clearInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shopId);
  }
}