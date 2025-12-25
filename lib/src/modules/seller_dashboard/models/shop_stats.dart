import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/models/shops.dart';

class ShopStats {
  final Shop shop;
  final List<Order> orders;
  ShopStats({required this.shop, required this.orders});
}