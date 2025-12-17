import '../models/product.dart';
import '../models/banner.dart';

class MockData {
  static List<BannerModel> getBanners() {
    return [
      BannerModel(
        id: 1,
        title: 'FREESHIP',
        subtitle: '0đ',
        imageUrl: '',
        backgroundColor: '#9C27B0',
        buttonText: 'Mua ngay',
        displayOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      BannerModel(
        id: 2,
        title: 'PHÁ ĐẢO',
        subtitle: 'TRIỆU DEAL',
        imageUrl: '',
        backgroundColor: '#7B1FA2',
        buttonText: 'Săn ngay',
        displayOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      BannerModel(
        id: 3,
        title: 'XỬ LÝ HÀNG',
        subtitle: 'TẠI KHO',
        imageUrl: '',
        backgroundColor: '#6A1B9A',
        buttonText: 'Xem ngay',
        displayOrder: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  static List<Product> getProducts() {
    return [
      Product(
        id: 1,
        name: 'Nike Sneakers',
        description: 'Nike Air Jordan Retro 1 Low Mystic Black',
        price: 1200000,
        imageUrl: 'assets/images/images1.jpg',
        rating: 4.0,
        reviewCount: 46890,
        categoryId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 2,
        name: 'Nike Sneakers',
        description: 'Mid Peach Mocha Shoes For Man White Black Pink S...',
        price: 1300243,
        imageUrl: 'assets/images/images2.jpg',
        rating: 4.5,
        reviewCount: 256890,
        categoryId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}