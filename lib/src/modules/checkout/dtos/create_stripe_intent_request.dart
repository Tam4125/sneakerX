class CreateStripeIntentRequest {
  final int userId;
  final double amount;
  final String currency;
  final String userEmail;

  CreateStripeIntentRequest({
    required this.userId,
    required this.amount,
    required this.currency,
    required this.userEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'userEmail': userEmail,
    };
  }

}