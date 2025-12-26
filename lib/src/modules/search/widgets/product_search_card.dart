import 'package:flutter/material.dart';
import 'package:sneakerx/src/models/product.dart';

class ProductSearchCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductSearchCard({
    Key? key,
    required this.product,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          // MainAxisSize.min giúp thẻ co lại vừa đủ nội dung, không chiếm hết chỗ
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- PHẦN 1: ẢNH (Đã sửa lỗi layout và cắt góc) ---
            // Bỏ Expanded, dùng Container có chiều cao cụ thể cho vùng ảnh
            Container(
              height: 150, // Chiều cao cố định cho vùng ảnh (bạn có thể chỉnh số này)
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50], // Nền xám nhạt
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.images.first.imageUrl,
                  // QUAN TRỌNG: fit: BoxFit.contain giúp hiển thị TRỌN VẸN ảnh
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),

            // --- PHẦN 2: THÔNG TIN ---
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Column(
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold, // Đậm hơn chút cho dễ đọc
                      color: Colors.black87,
                    ),
                    maxLines: 2, // Cho phép xuống dòng nếu tên dài
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}