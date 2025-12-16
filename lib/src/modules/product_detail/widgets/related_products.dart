import 'package:flutter/material.dart';
import '../../../data/datasources/mock_product_data.dart';
import '../../../config/app_colors.dart';

class RelatedProducts extends StatelessWidget {
  final List<RelatedProductModel> products;

  const RelatedProducts({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER: Tiêu đề + Sort + Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SẢN PHẨM KHÁC CỦA SHOP",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "282+ Sản phẩm",
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Nút Sort & Filter
              Row(
                children: [
                  _buildActionButton("Sort", Icons.import_export),
                  const SizedBox(width: 3),
                  _buildActionButton("Filter", Icons.filter_alt_outlined),
                ],
              )
            ],
          ),

          const SizedBox(height: 16),

          // 2. LIST SẢN PHẨM
          SizedBox(
            height: 310, // Tăng chiều cao để chứa đủ mô tả và sao
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 10, right: 10, left: 2),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(products[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget nút Sort/Filter
  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Icon(icon, size: 16, color: Colors.black87),
        ],
      ),
    );
  }

  // Widget Card Sản phẩm (Đã thêm mô tả & sao)
  Widget _buildProductCard(RelatedProductModel product) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        // Hiệu ứng đổ bóng nổi (Shadow)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ẢNH SẢN PHẨM
          Expanded(
            flex: 7, // Chiếm 6 phần chiều cao
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[100]),
              ),
            ),
          ),

          // 2. THÔNG TIN (Tên, Mô tả, Giá, Sao)
          Expanded(
            flex: 5, // Chiếm 5 phần chiều cao
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên chính (Đậm)
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87
                        ),
                      ),
                      const SizedBox(height: 4),
                      // MÔ TẢ NHỎ (Màu xám, font nhỏ) -> THÊM MỚI
                      const Text(
                        "Giày thể thao nam nữ, thiết kế năng động, êm chân",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.2
                        ),
                      ),
                    ],
                  ),

                  // Giá và Sao
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Giá tiền
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                        ),
                      ),
                      const SizedBox(height: 6),
                      // HÀNG SAO VÀNG -> THÊM MỚI
                      Row(
                        children: [
                          // Tạo 5 ngôi sao vàng
                          ...List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFFFC107), size: 14)),
                          const SizedBox(width: 6),
                          // Số lượng đánh giá
                          const Text(
                              "6,890",
                              style: TextStyle(color: Colors.grey, fontSize: 11)
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}