import 'package:sneakerx/src/models/enums/payment_status.dart';

class UpdatePaymentStatusRequest {
  final int paymentId;
  final PaymentStatus paymentStatus;

  UpdatePaymentStatusRequest({
    required this.paymentStatus,
    required this.paymentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'paymentStatus': paymentStatus.name,
    };
  }

}