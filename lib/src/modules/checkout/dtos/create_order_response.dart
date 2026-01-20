class CreateOrderResponse {
  final int orderId;
  final int paymentId;

  CreateOrderResponse({required this.orderId, required this.paymentId});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: json['orderId'],
      paymentId: json['paymentId'],
    );
  }
}