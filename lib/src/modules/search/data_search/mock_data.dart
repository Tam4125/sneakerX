// FILE: lib/src/modules/search/data_search/mock_data.dart

import '../models_search/search_history.dart';

class MockData {
  // 1. Giả lập dữ liệu Lịch sử tìm kiếm
  static List<SearchHistory> getSearchHistory() {
    return [
      SearchHistory(id: 1, keyword: 'Nike Air Max', searchedAt: DateTime.now()),
      SearchHistory(id: 2, keyword: 'Adidas Ultraboost', searchedAt: DateTime.now()),
      SearchHistory(id: 3, keyword: 'New Balance 574', searchedAt: DateTime.now()),
      SearchHistory(id: 4, keyword: 'MLB Big Ball', searchedAt: DateTime.now()),
      SearchHistory(id: 5, keyword: 'giày chạy bộ', searchedAt: DateTime.now()),
      SearchHistory(id: 6, keyword: 'giày thể thao nam', searchedAt: DateTime.now()),
    ];
  }
}