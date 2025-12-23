import 'package:flutter/material.dart';
// Import trỏ về folder models
import '../../models/product.dart';
import '../../models/product_image.dart';
import '../../models/product_variant.dart';
import '../../models/product_review.dart';

class NewMockData {
  // Dữ liệu sản phẩm mẫu (Khớp với Model ở Bước 1)
  static List<Product> getProducts() {
    return [
      Product(
        productId: 1,
        shopId: 101,
        categoryId: 1,
        name: 'Nike Air Jordan Retro 1',
        description: 'Giày thể thao...',
        price: 1200000,           // Giá để test lọc
        rating: 4.5,
        soldCount: 469,
        category: 'Giày',         // Category để test lọc
        createdAt: DateTime.now(),
        images: [
          ProductImage(imageId: 1, imageUrl: 'assets/images/images1.jpg'),
        ],
        variants: [], reviews: [],
      ),
      Product(
        productId: 2,
        shopId: 102,
        categoryId: 2,
        name: 'Áo Thun Nam Cotton',
        description: 'Áo thun mát mẻ...',
        price: 150000,
        rating: 4.8,
        soldCount: 1200,
        category: 'Quần áo',
        createdAt: DateTime.now(),
        images: [
          ProductImage(imageId: 2, productId: 2, imageUrl: 'assets/images/images2.jpg', sortOrder: 1),
        ],
        variants: [], reviews: [],
      ),
      // Bạn có thể thêm SP thứ 3 là "Phụ kiện" để test đủ bộ lọc
    ];
  }
}