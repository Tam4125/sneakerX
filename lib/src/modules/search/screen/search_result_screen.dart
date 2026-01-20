import 'package:flutter/material.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/search/widgets/product_list.dart';
import 'package:sneakerx/src/services/product_service.dart';
import 'package:sneakerx/src/modules/search/dtos/filter_query.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../models_search/filter_options.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultScreen({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  // State for Real Data
  List<Product> _searchResults = [];
  bool _isLoading = false;

  // Keep track of current filter options
  FilterOptions _currentFilter = FilterOptions();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _performSearch();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Construct the FilterQuery object for the backend
      // FIX: Map 'categoryId' from FilterOptions to FilterQuery
      FilterQuery query = FilterQuery(
        q: _searchController.text.isEmpty ? null : _searchController.text,
        categoryId: _currentFilter.categoryId,
        minPrice: _currentFilter.minPrice,
        maxPrice: _currentFilter.maxPrice,
      );

      // 2. Call the API
      final response = await _productService.searchProducts(query);

      if (response.success && mounted) {
        setState(() {
          _searchResults = response.data!;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Search error: $e");
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => FilterBottomSheet(
          initialFilter: _currentFilter,
          onApply: (filter) {
            // User clicked "Apply" in the bottom sheet
            setState(() {
              _currentFilter = filter; // Update local filter state
            });
            _performSearch(); // Trigger new API call
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: SearchBarWidget(
          controller: _searchController,
          hintText: 'Search...',
          onSearch: _performSearch, // Triggers API call on enter
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Search Result',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_searchResults.length} products',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Product List
            _searchResults.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Suitable products not found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ProductList(products: _searchResults),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}