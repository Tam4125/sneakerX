class UpdateCartRequest {
  final Map<int, int> updatedQuantities;

  UpdateCartRequest({required this.updatedQuantities});

  Map<String, dynamic> toJson() {
    return {
      'updatedQuantities': updatedQuantities.map((key, val) => MapEntry(key.toString(), val))
    };
  }
}