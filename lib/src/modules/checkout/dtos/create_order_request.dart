import 'package:sneakerx/src/models/enums/payment_status.dart';
import 'package:sneakerx/src/models/enums/payment_method.dart';

class CreateOrderRequest {
  final int addressId;

  final Map<int, String> noteMap;
  final Map<int, List<int>> itemMap;
  final Map<int, double> shippingFeeMap;
  final Map<int, double> subTotalMap;
  final double totalAmount;

  final SneakerXPaymentMethod paymentMethod;
  final String transactionId;
  final PaymentStatus paymentStatus;

  CreateOrderRequest({
    required this.addressId,
    required this.noteMap,
    required this.itemMap,
    required this.shippingFeeMap,
    required this.subTotalMap,
    required this.totalAmount,
    required this.paymentMethod,
    required this.transactionId,
    required this.paymentStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'noteMap': noteMap.map((key, val) => MapEntry(key.toString(), val)),
      'itemMap': itemMap.map((key, val) => MapEntry(key.toString(), val)),
      'totalAmount': totalAmount,
      'shippingFeeMap': shippingFeeMap.map((key, val) => MapEntry(key.toString(), val)),
      'subTotalMap': subTotalMap.map((key, val) => MapEntry(key.toString(), val)),
      'paymentMethod': paymentMethod.name,
      'transactionId': transactionId,
      'paymentStatus': paymentStatus.name
    };
  }

}