class ProductCategory {
  final int categoryId;
  final String description;
  final String name;
  final DateTime? createdAt;

  ProductCategory({
    required this.categoryId,
    required this.description,
    required this.name,
    this.createdAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      categoryId: json['categoryId'],
      description: json['description'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt'])
    );
  }
}