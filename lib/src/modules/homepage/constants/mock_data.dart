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
      ),
      BannerModel(
        id: 2,
        title: 'PHÁ ĐẢO',
        subtitle: 'TRIỆU DEAL',
        imageUrl: '',
        backgroundColor: '#7B1FA2',
        buttonText: 'Săn ngay',
        displayOrder: 2,
      ),
      BannerModel(
        id: 3,
        title: 'XỬ LÝ HÀNG',
        subtitle: 'TẠI KHO',
        imageUrl: '',
        backgroundColor: '#6A1B9A',
        buttonText: 'Xem ngay',
        displayOrder: 3,
      ),
    ];
  }
}