class CreateOrderRequest {
  final int addressId;
  final double shippingFee;
  final List<int> cartItems;
  final String provider;
  final String transactionId;
  final String orderStatus;

  CreateOrderRequest({
    required this.addressId,
    required this.shippingFee,
    required this.cartItems,
    required this.provider,
    required this.transactionId,
    required this.orderStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'shippingFee': shippingFee,
      'cartItems': cartItems,
      'provider': provider,
      'transactionId': transactionId,
      'orderStatus': orderStatus
    };
  }

}