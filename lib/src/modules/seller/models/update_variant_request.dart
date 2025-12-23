class VariantUpdateDto {
  int? variantId;
  String variantType; // e.g., "SIZE", "COLOR"
  String variantValue; // e.g., "42", "Red"
  double price;
  int stock;

  VariantUpdateDto({
    this.variantId,
    required this.variantType,
    required this.variantValue,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toJson() => {
    'variantId': variantId,
    'variantType': variantType,
    'variantValue': variantValue,
    'price': price,
    'stock': stock,
  };
}