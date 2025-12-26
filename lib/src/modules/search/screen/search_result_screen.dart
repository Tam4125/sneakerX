import 'package:flutter/material.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/product_detail/view/product_detail_view.dart';
import 'package:sneakerx/src/services/product_service.dart';
import 'package:sneakerx/src/modules/search/dtos/filter_query.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_history_chip.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/product_search_card.dart';
import '../data_search/mock_data.dart';
import '../models_search/search_history.dart';
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

  // Local Search History
  List<SearchHistory> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _loadHistory();
    _performSearch();
  }

  void _loadHistory() {
    setState(() {
      _searchHistory = MockData.getSearchHistory().take(3).toList();
    });
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
      final results = await _productService.searchProducts(query);

      if (mounted) {
        setState(() {
          _searchResults = results ?? [];
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

  void _deleteHistoryItem(int id) {
    setState(() {
      _searchHistory.removeWhere((item) => item.id == id);
    });
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
            // 1. Search History Section
            if (_searchHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _searchHistory.map((item) {
                    return SearchHistoryChip(
                      keyword: item.keyword,
                      onTap: () {
                        _searchController.text = item.keyword;
                        _performSearch();
                      },
                      onDelete: () => _deleteHistoryItem(item.id),
                    );
                  }).toList(),
                ),
              ),

            if (_searchHistory.isNotEmpty)
              Divider(height: 1, thickness: 1, color: Colors.grey[200]),

            // 2. Result Count
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kết quả tìm kiếm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_searchResults.length} sản phẩm',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Product List (Real Data)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _searchResults.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy sản phẩm nào',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return ProductSearchCard(
                    product: _searchResults[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailView(productId: _searchResults[index].productId))
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}