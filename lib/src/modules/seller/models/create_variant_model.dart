class CreateVariantRequest {
  String variantType; // e.g., "SIZE", "COLOR"
  String variantValue; // e.g., "42", "Red"
  double price;
  int stock;

  CreateVariantRequest({
    required this.variantType,
    required this.variantValue,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toJson() => {
    'variantType': variantType,
    'variantValue': variantValue,
    'price': price,
    'stock': stock,
  };
}