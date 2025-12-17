class Category {
  final int id;
  final String name;
  final String iconText;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.iconText,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
}