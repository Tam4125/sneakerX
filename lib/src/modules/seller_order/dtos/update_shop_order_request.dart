import 'package:sneakerx/src/models/enums/order_status.dart';

class UpdateShopOrderRequest {
  final int shopOrderId;
  final OrderStatus orderStatus;

  UpdateShopOrderRequest({
    required this.shopOrderId,
    required this.orderStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'shopOrderId': shopOrderId,
      'orderStatus': orderStatus.name,
    };
  }
}