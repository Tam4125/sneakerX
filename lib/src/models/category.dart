class ProductCategory {
  final int categoryId;
  final String description;
  final String name;

  ProductCategory({
    required this.categoryId,
    required this.description,
    required this.name,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      categoryId: json['categoryId'],
      description: json['description'],
      name: json['name'],
    );
  }
}