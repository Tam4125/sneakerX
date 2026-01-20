import 'package:sneakerx/src/models/enums/payment_method.dart';
import 'package:sneakerx/src/models/enums/payment_status.dart';

class Payment {
  final int paymentId;
  final int orderId;
  final int userId;
  final double amount;
  final SneakerXPaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String transactionId;
  final DateTime createdAt;

  Payment({
    required this.paymentId,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.transactionId,
    required this.createdAt
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      orderId: json['orderId'],
      userId: json['userId'],
      amount: json['amount'],
      paymentMethod: SneakerXPaymentMethod.values.byName(json['paymentMethod']),
      paymentStatus: PaymentStatus.values.byName(json['paymentStatus']),
      transactionId: json['transactionId'],
      createdAt: DateTime.parse(json['createdAt'])
    );
  }
}