import '../models/product.dart';
import '../models/product_variant.dart';
import '../models/product_image.dart';

class MockProductData {
  // 1. SẢN PHẨM CHÍNH
  static final Product product = Product(
    productId: 1,
    shopId: 101,
    categoryId: 5,
    name: "Giày Thể Thao JD1 High-Top Retro Phối Màu Cực Chất, Da Mềm Êm Chân",
    description: "Chất liệu da cao cấp, đế cao su chống trơn trượt. Thiết kế cổ cao ôm chân, phong cách trẻ trung năng động. Phù hợp đi chơi, đi học, thể thao.",
    price: 1148000,
    stock: 100,
    soldCount: 2000,
    rating: 4.8,
    status: ProductStatus.active,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // 2. NHIỀU ẢNH SLIDER HƠN (Đã cập nhật link sống tốt)
  static final List<ProductImage> images = [
    // Ảnh 1: Màu Đỏ/Trắng (Giống Jordan Chicago)
    ProductImage(imageId: 1, productId: 1, imageUrl: "https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=800&q=80", sortOrder: 1),
    // Ảnh 2: Màu Cam/Vàng
    ProductImage(imageId: 2, productId: 1, imageUrl: "https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?auto=format&fit=crop&w=800&q=80", sortOrder: 2),
    // Ảnh 3: Màu Xám/Trắng
    ProductImage(imageId: 3, productId: 1, imageUrl: "https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=800&q=80", sortOrder: 3),
    // Ảnh 4: Màu Xanh Dương
    ProductImage(imageId: 4, productId: 1, imageUrl: "https://images.unsplash.com/photo-1579338559194-a162d19bf842?auto=format&fit=crop&w=800&q=80", sortOrder: 4),
    // Ảnh 5: Góc chụp đế giày/Chi tiết
    ProductImage(imageId: 5, productId: 1, imageUrl: "https://images.unsplash.com/photo-1603808033192-082d6919d3e1?auto=format&fit=crop&w=800&q=80", sortOrder: 5),
  ];

  // 3. NHIỀU SIZE VÀ MÀU HƠN
  static final List<ProductVariant> variants = [
    // Size 36-43
    ProductVariant(variantId: 1, productId: 1, variantType: "size", variantValue: "36", price: 1148000, stock: 10),
    ProductVariant(variantId: 2, productId: 1, variantType: "size", variantValue: "37", price: 1148000, stock: 10),
    ProductVariant(variantId: 3, productId: 1, variantType: "size", variantValue: "38", price: 1148000, stock: 10),
    ProductVariant(variantId: 4, productId: 1, variantType: "size", variantValue: "39", price: 1148000, stock: 10),
    ProductVariant(variantId: 5, productId: 1, variantType: "size", variantValue: "40", price: 1148000, stock: 10),
    ProductVariant(variantId: 6, productId: 1, variantType: "size", variantValue: "41", price: 1148000, stock: 10),
    ProductVariant(variantId: 7, productId: 1, variantType: "size", variantValue: "42", price: 1148000, stock: 10),
    ProductVariant(variantId: 8, productId: 1, variantType: "size", variantValue: "43", price: 1148000, stock: 10),

    // Nhiều màu: Đỏ, Xanh, Vàng, Đen, Trắng, Tím
    ProductVariant(variantId: 10, productId: 1, variantType: "color", variantValue: "0xFFFF0000", price: 1148000, stock: 5), // Đỏ
    ProductVariant(variantId: 11, productId: 1, variantType: "color", variantValue: "0xFF0000FF", price: 1148000, stock: 5), // Xanh dương
    ProductVariant(variantId: 12, productId: 1, variantType: "color", variantValue: "0xFFFFFF00", price: 1148000, stock: 5), // Vàng
    ProductVariant(variantId: 13, productId: 1, variantType: "color", variantValue: "0xFF000000", price: 1148000, stock: 5), // Đen
    ProductVariant(variantId: 14, productId: 1, variantType: "color", variantValue: "0xFF808080", price: 1148000, stock: 5), // Xám
    ProductVariant(variantId: 15, productId: 1, variantType: "color", variantValue: "0xFF8E44AD", price: 1148000, stock: 5), // Tím
  ];

  // 4. DANH SÁCH SẢN PHẨM KHÁC (Đã cập nhật link ảnh)
  static final List<RelatedProductModel> relatedProducts = [
    RelatedProductModel(
      name: "Nike Air Jordan 1 Low Black",
      price: 1200000,
      imageUrl: "https://images.unsplash.com/photo-1539185441755-769473a23570?auto=format&fit=crop&w=800&q=80",
    ),
    RelatedProductModel(
      name: "Adidas Yeezy Boost 350",
      price: 5300000,
      imageUrl: "https://images.unsplash.com/photo-1584735175315-9d5df23860e6?auto=format&fit=crop&w=800&q=80",
    ),
    RelatedProductModel(
      name: "Converse Chuck Taylor High",
      price: 950000,
      imageUrl: "https://images.unsplash.com/photo-1607522370275-f14206c1ab41?auto=format&fit=crop&w=800&q=80",
    ),
    RelatedProductModel(
      name: "New Balance 550 White",
      price: 2100000,
      imageUrl: "https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?auto=format&fit=crop&w=800&q=80",
    ),
    RelatedProductModel(
      name: "Vans Old Skool Classic",
      price: 1100000,
      imageUrl: "https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=800&q=80",
    ),
  ];
}

class RelatedProductModel {
  final String name;
  final double price;
  final String imageUrl;
  RelatedProductModel({required this.name, required this.price, required this.imageUrl});

  String get formattedPrice {
    return "${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";
  }
}