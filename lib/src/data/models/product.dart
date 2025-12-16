enum ProductStatus { active, hidden, banned }

class Product {
  final int productId;      // PK
  final int shopId;         // FK
  final int categoryId;     // FK
  final String name;
  final String description;
  final double price;
  final int stock;
  final int soldCount;
  final double rating;
  final ProductStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.productId,
    required this.shopId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.soldCount,
    required this.rating,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedPrice {
    return "${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";
  }
}