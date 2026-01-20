import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sneakerx/src/models/category.dart';
import 'package:sneakerx/src/services/category_service.dart';
import '../models_search/filter_options.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterOptions initialFilter;
  final Function(FilterOptions) onApply;

  const FilterBottomSheet({
    Key? key,
    required this.initialFilter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final CategoryService _categoryService = CategoryService();

  List<ProductCategory> _categories = [];
  bool _isLoading = true;
  int? _selectedCategoryId;

  // Controllers for Price
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _fetchCategories();
  }

  void _loadInitialData() {
    // 1. Load Category ID
    _selectedCategoryId = widget.initialFilter.categoryId;

    // 2. Load Prices into Controllers
    if (widget.initialFilter.minPrice != null) {
      _minPriceController.text = widget.initialFilter.minPrice!.toInt().toString();
    }
    if (widget.initialFilter.maxPrice != null) {
      _maxPriceController.text = widget.initialFilter.maxPrice!.toInt().toString();
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _categoryService.getCategories();

      if (response.success && mounted) {
        setState(() {
          _categories = response.data!;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handle keyboard covering bottom sheet
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- HEADER ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Search Filter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // --- BODY ---
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CATEGORY FILTER (Dynamic)
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_categories.isEmpty)
                    const Text("Category not found", style: TextStyle(color: Colors.grey))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSelected = _selectedCategoryId == category.categoryId; // Assuming model has categoryId
                        return FilterChip(
                          label: Text(category.name), // Assuming model has name
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              // Toggle logic: If clicking selected one, unselect it
                              if (isSelected) {
                                _selectedCategoryId = null;
                              } else {
                                _selectedCategoryId = category.categoryId;
                              }
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.orange[100],
                          checkmarkColor: Colors.orange[700],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.orange[900] : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 24),

                  // 2. PRICE RANGE FILTER
                  const Text(
                    'Price',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceInput(
                          controller: _minPriceController,
                          hint: 'Min',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          height: 1,
                          width: 10,
                          color: Colors.grey[400],
                        ),
                      ),
                      Expanded(
                        child: _buildPriceInput(
                          controller: _maxPriceController,
                          hint: 'Max',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- FOOTER BUTTONS ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // RESET
                      setState(() {
                        _selectedCategoryId = null;
                        _minPriceController.clear();
                        _maxPriceController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.orange[700]!),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // APPLY: Create the object only when sending back
                      final resultOptions = FilterOptions(
                        categoryId: _selectedCategoryId,
                        minPrice: double.tryParse(_minPriceController.text),
                        maxPrice: double.tryParse(_maxPriceController.text),
                      );

                      widget.onApply(resultOptions);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.orange[700],
                    ),
                    child: const Text(
                        'Apply',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput({required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          isDense: true,
        ),
      ),
    );
  }
}