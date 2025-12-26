// lib/src/models_search/filter_options.dart
class FilterOptions {
  int? categoryId; // Changed from List<String> selectedBrands
  double? minPrice;
  double? maxPrice;

  FilterOptions({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
  });
}