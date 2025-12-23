
import 'package:sneakerx/src/modules/seller_order/models/seller_order.dart';

class OrderMockData {
  static List<SellerOrder> GetShopData() {
    return [
      SellerOrder(
        shopId: 1,
        userId: 1,
        orderId: 56789230947637,
        productId: 1,
        provider: 'COD',
        orderStatus: 'Shipped',
        totalPrice: 6700000,
        createdAt: DateTime.now(),
        name: 'Nike Air Max 90 Grey',
        image: 'assets/images/nikeairmax90.png'
      ),
      SellerOrder(
          shopId: 1,
          userId: 2,
          orderId: 5637845968473,
          productId: 2,
          provider: 'MOMO',
          orderStatus: 'Delivered',
          totalPrice: 7800000,
          createdAt: DateTime.now(),
          name: 'Puma Speedcat Black',
          image: 'assets/images/pumaspeedcatblack.jpg'
      ),
      SellerOrder(
          shopId: 1,
          userId: 3,
          orderId: 657895473825,
          productId: 3,
          provider: 'VISA',
          orderStatus: 'Pending',
          totalPrice: 3600000,
          createdAt: DateTime.now(),
          name: 'Nike SB Dunk Low Pro Laser Orange / Regency Purple Lakers',
          image: 'assets/images/nikesbdunklakers.jpg'
      ),
    ];
  }
}