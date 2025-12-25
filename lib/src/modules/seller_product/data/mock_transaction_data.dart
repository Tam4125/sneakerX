class Transaction {
  final String id;
  final int amount;
  final String from;
  final String message;
  final String type;
  final DateTime date;

  Transaction({
    required this.id,
    required this.amount,
    required this.from,
    required this.message,
    required this.type,
    required this.date,
  });
}

class MockTransactionData {
  static final List<Transaction> products = [
    Transaction(
      id: '456728489',
      amount: 67000000,
      from: 'Tú Senna',
      message: 'a hết tiền gửi chú r',
      type: 'income',
      date: DateTime.now(),
    ),
  ];
}