class FilterOptions {
  List<String> selectedBrands;
  String? priceRange;

  FilterOptions({
    this.selectedBrands = const [],
    this.priceRange,
  });

  FilterOptions copyWith({
    List<String>? selectedBrands,
    String? priceRange,
  }) {
    return FilterOptions(
      selectedBrands: selectedBrands ?? this.selectedBrands,
      priceRange: priceRange ?? this.priceRange,
    );
  }
}