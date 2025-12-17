import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(price);
  }

  String _formatReviewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      final k = count / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PHẦN 1: ẢNH SẢN PHẨM (Sửa: Dùng AspectRatio để ảnh luôn vuông 1:1)
          AspectRatio(
            aspectRatio: 1.0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
              child: product.imageUrl.isNotEmpty
                  ? Image.asset( // Hoặc Image.network tùy dữ liệu của bạn
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
              )
                  : _buildErrorImage(),
            ),
          ),

          // PHẦN 2: THÔNG TIN (Sửa: Dùng Expanded để chiếm phần còn lại)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Giảm padding từ 10 xuống 8 để tiết kiệm chỗ
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Quan trọng: Đẩy nội dung ra 2 đầu
                children: [
                  // Block tên và mô tả
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Chỉ chiếm diện tích cần thiết
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // Giảm nhẹ font size nếu cần
                        ),
                        maxLines: 2, // Cho phép tên dài 2 dòng
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Đã xóa phần Description để tránh vỡ layout.
                      // Shopee ở màn hình ngoài thường ít hiện mô tả chi tiết vì tốn chỗ.
                      // Nếu muốn hiện, hãy đảm bảo GridView đủ cao.
                    ],
                  ),

                  // Block Giá và Rating
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            if (index < product.rating.floor()) {
                              return Icon(Icons.star, color: Colors.orange[600], size: 12); // Giảm size icon
                            } else if (index < product.rating) {
                              return Icon(Icons.star_half, color: Colors.orange[600], size: 12);
                            } else {
                              return Icon(Icons.star_border, color: Colors.grey[400], size: 12);
                            }
                          }),
                          SizedBox(width: 4),
                          Text(
                            _formatReviewCount(product.reviewCount),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
      ),
    );
  }
}