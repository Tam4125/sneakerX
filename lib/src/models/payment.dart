class Payment {
  final int paymentId;
  final int orderId;
  final int userId;
  final double amount;
  final String provider;
  final String paymentStatus;
  final String transactionId;

  Payment({
    required this.paymentId,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.provider,
    required this.paymentStatus,
    required this.transactionId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      orderId: json['orderId'],
      userId: json['userId'],
      amount: json['amount'],
      provider: json['provider'],
      paymentStatus: json['paymentStatus'],
      transactionId: json['transactionId'],
    );
  }
}