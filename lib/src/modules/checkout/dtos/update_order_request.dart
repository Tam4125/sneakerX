import 'package:sneakerx/src/models/enums/order_status.dart';

class UpdateOrderStatusRequest {
  final OrderStatus orderStatus;
  final int orderId;

  UpdateOrderStatusRequest({
    required this.orderStatus,
    required this.orderId,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderStatus': orderStatus.name,
      'orderId': orderId
    };
  }

}