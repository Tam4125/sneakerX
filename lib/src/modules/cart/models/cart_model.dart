// --- MODEL RIÊNG CHO CART ---
class CartItemModel {
  final String name;
  final double price;
  final String imageUrl;
  final String size;
  final String colorName;
  int quantity;

  CartItemModel({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.size,
    required this.colorName,
    this.quantity = 1,
  });
}