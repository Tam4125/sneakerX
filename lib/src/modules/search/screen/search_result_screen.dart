import 'package:flutter/material.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_history_chip.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/product_search_card.dart';
import '../data_search/mock_data.dart';        // Trỏ sang data_search
import '../models_search/search_history.dart'; // Trỏ sang models_search
import '../models_search/product.dart';        // Trỏ sang models_search
import '../models_search/filter_options.dart'; // Trỏ sang models_search

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
  final TextEditingController _searchController = TextEditingController();
  List<SearchHistory> searchHistory = [];
  List<Product> searchResults = [];
  FilterOptions currentFilter = FilterOptions();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _loadData();
    _performSearch();
  }

  void _loadData() {
    // Lấy lịch sử tìm kiếm từ MockData
    searchHistory = MockData.getSearchHistory().take(3).toList();
  }

  void _performSearch() {
    setState(() {
      // Gọi hàm search từ MockData
      searchResults = MockData.searchProducts(
        _searchController.text,
        filter: currentFilter,
      );
    });
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
          initialFilter: currentFilter,
          onApply: (filter) {
            setState(() {
              currentFilter = filter;
              _performSearch();
            });
          },
        ),
      ),
    );
  }

  void _deleteHistoryItem(int id) {
    setState(() {
      searchHistory.removeWhere((item) => item.id == id);
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
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: SearchBarWidget(
          controller: _searchController,
          hintText: 'Search...',
          onSearch: _performSearch,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Phần Lịch sử tìm kiếm (Search History)
            if (searchHistory.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: searchHistory.map((item) {
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

            if (searchHistory.isNotEmpty)
              Divider(height: 1, thickness: 1, color: Colors.grey[200]),

            // 2. Số lượng kết quả
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kết quả tìm kiếm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${searchResults.length} sản phẩm',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Danh sách sản phẩm (Search Results)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: searchResults.isEmpty
                  ? Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                      SizedBox(height: 16),
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
                physics: NeverScrollableScrollPhysics(), // Để scroll theo SingleChildScrollView
                itemCount: searchResults.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return ProductSearchCard(
                    product: searchResults[index],
                    onTap: () {
                      // Xử lý khi bấm vào sản phẩm (Ví dụ chuyển sang màn Detail)
                      print("Đã chọn: ${searchResults[index].name}");
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 30), // Khoảng trống dưới cùng
          ],
        ),
      ),
    );
  }
}