import 'package:flutter/material.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/product_detail/view/product_detail_view.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  String _formatSoldCount(int soldCount) {
    if (soldCount >= 1000000) {
      return '${(soldCount / 1000000).toStringAsFixed(1)}M';
    } else if (soldCount >= 1000) {
      final k = soldCount / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return soldCount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              // Pass the current 'productId' object to the next screen
                builder: (context) => ProductDetailScreen(productId: product.productId)
            )
        );
      },
      child: Container(
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
                child: product.images.isNotEmpty
                    ? Image.network( // Hoặc Image.network tùy dữ liệu của bạn
                  product.images.first.imageUrl,
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
                    Flexible(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis, // Cắt bớt bằng "..."
                      ),
                    ),

                    // Block Giá và Rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppConfig.formatCurrency(product.basePrice),
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
                            Expanded( // Thêm Expanded ở đây phòng trường hợp số lượng bán quá dài
                              child: Text(
                                'Sold ${_formatSoldCount(product.soldCount)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
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