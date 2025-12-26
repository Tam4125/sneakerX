class FilterQuery {
  final String? q;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;

  FilterQuery({
    this.q,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
  });
}