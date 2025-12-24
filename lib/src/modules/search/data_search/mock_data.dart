// FILE: lib/src/modules/search/data_search/mock_data.dart

import '../models_search/product.dart';
import '../models_search/search_history.dart';
import '../models_search/filter_options.dart';

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

  // 2. Giả lập danh sách tất cả sản phẩm
  static List<Product> getAllShoes() {
    return [
      // --- NIKE ---
      Product(
        id: 1,
        name: 'Air Max 270',
        brand: 'Nike',
        description: 'Nike Air Max 270 - Perfect for Daily Wear',
        price: 2500000,
        imageUrl: 'assets/images/images1.jpg',
        rating: 4.5,
        reviewCount: 1200,
        category: 'Nike',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 2,
        name: 'Air Jordan 1',
        brand: 'Nike',
        description: 'Nike Air Jordan 1 Retro High',
        price: 3500000,
        imageUrl: 'assets/images/images2.jpg',
        rating: 4.8,
        reviewCount: 2500,
        category: 'Nike',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 3,
        name: 'React Infinity',
        brand: 'Nike',
        description: 'Nike React Infinity Run',
        price: 2800000,
        imageUrl: 'assets/images/images1.jpg',
        rating: 4.6,
        reviewCount: 890,
        category: 'Nike',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // --- ADIDAS ---
      Product(
        id: 4,
        name: 'Ultraboost 22',
        brand: 'Adidas',
        description: 'Adidas Ultraboost 22 Running Shoes',
        price: 3200000,
        imageUrl: 'assets/images/images2.jpg',
        rating: 4.7,
        reviewCount: 1800,
        category: 'Adidas',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 5,
        name: 'Stan Smith',
        brand: 'Adidas',
        description: 'Adidas Stan Smith Classic White',
        price: 1800000,
        imageUrl: 'assets/images/images1.jpg',
        rating: 4.5,
        reviewCount: 3200,
        category: 'Adidas',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 6,
        name: 'NMD R1',
        brand: 'Adidas',
        description: 'Adidas NMD R1 Boost',
        price: 2600000,
        imageUrl: 'assets/images/images1.jpg',
        rating: 4.4,
        reviewCount: 1100,
        category: 'Adidas',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // --- NEW BALANCE ---
      Product(
        id: 7,
        name: '574 Classic',
        brand: 'New Balance',
        description: 'New Balance 574 Core Classic',
        price: 1500000,
        imageUrl: 'assets/images/images1.jpg',
        rating: 4.3,
        reviewCount: 650,
        category: 'New Balance',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 8,
        name: '990v5',
        brand: 'New Balance',
        description: 'New Balance 990v5 Made in USA',
        price: 4200000,
        imageUrl: 'assets/images/images1.jpg',
        rating: 4.9,
        reviewCount: 420,
        category: 'New Balance',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // --- MLB ---
      Product(
        id: 9,
        name: 'Big Ball Chunky',
        brand: 'MLB',
        description: 'MLB Big Ball Chunky A Classic',
        price: 1200000,
        imageUrl: 'assets/images/images1.jpg',
        rating: 4.2,
        reviewCount: 890,
        category: 'MLB',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 10,
        name: 'Playball Origin',
        brand: 'MLB',
        description: 'MLB Playball Origin Sneakers',
        price: 1400000,
        imageUrl: 'assets/images/images1.jpg',
        rating: 4.1,
        reviewCount: 560,
        category: 'MLB',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // 3. Hàm xử lý Tìm kiếm và Lọc
  static List<Product> searchProducts(String query, {FilterOptions? filter}) {
    var products = getAllShoes();

    // Lọc theo từ khóa (Keyword)
    if (query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      products = products.where((p) {
        return p.name.toLowerCase().contains(lowercaseQuery) ||
            p.brand.toLowerCase().contains(lowercaseQuery) ||
            p.description.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }

    // Lọc theo Thương hiệu (Brand)
    // Lưu ý: Đảm bảo 'category' trong Product trùng với tên Brand trong Filter
    if (filter != null && filter.selectedBrands.isNotEmpty) {
      products = products.where((p) => filter.selectedBrands.contains(p.category)).toList();
    }

    // Lọc theo Khoảng giá (Price Range)
    if (filter != null && filter.priceRange != null) {
      products = products.where((p) {
        switch (filter.priceRange) {
          case 'Dưới 1 triệu':
            return p.price < 1000000;
          case '1 - 2 triệu':
            return p.price >= 1000000 && p.price < 2000000;
          case '2 - 5 triệu':
            return p.price >= 2000000 && p.price < 5000000;
          case 'Trên 5 triệu':
            return p.price >= 5000000;
          default:
            return true;
        }
      }).toList();
    }

    return products;
  }
}