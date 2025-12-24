class CreateStripeIntentResponse {
  final String clientSecret; // The "Ticket" Flutter needs
  final String transactionId;

  CreateStripeIntentResponse({
    required this.clientSecret,
    required this.transactionId,
  });

  factory CreateStripeIntentResponse.fromJson(Map<String, dynamic> json) {
    return CreateStripeIntentResponse(
      clientSecret: json['clientSecret'],
      transactionId: json['transactionId'],
    );
  }
}