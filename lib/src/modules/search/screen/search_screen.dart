import 'package:flutter/material.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_history_chip.dart';
import '../widgets/product_search_card.dart';
import '../data_search/mock_data.dart';
import '../models_search/search_history.dart';
import '../models_search/product.dart'; // Lưu ý: Nếu báo lỗi, hãy đổi thành package:sneakerx/src/models/product.dart
import 'search_result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchHistory> searchHistory = [];
  List<Product> suggestedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    searchHistory = MockData.getSearchHistory();
    suggestedProducts = MockData.getAllShoes().take(4).toList();
  }

  void _performSearch() {
    if (_searchController.text.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(
          searchQuery: _searchController.text.trim(),
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: SearchBarWidget(
          controller: _searchController,
          hintText: 'Tìm kiếm sản phẩm...',
          onSearch: _performSearch,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN 1: LỊCH SỬ TÌM KIẾM ---
            if (searchHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Lịch sử tìm kiếm",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
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
                  ],
                ),
              ),

            const Divider(thickness: 1, color: Color(0xFFEEEEEE)),

            // --- PHẦN 2: GỢI Ý SẢN PHẨM ---
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Gợi ý cho bạn',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suggestedProducts.length,
                // Tăng khoảng cách giữa các card lên 16 cho thoáng mắt
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  // --- ĐÃ SỬA: BỎ SIZEDBOX CỐ ĐỊNH CHIỀU CAO ---
                  // Card sẽ tự động tính chiều cao dựa trên ảnh và nội dung
                  return ProductSearchCard(
                    product: suggestedProducts[index],
                    onTap: () {
                      print("Đã chọn: ${suggestedProducts[index].name}");
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}