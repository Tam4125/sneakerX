import 'dart:ffi';

import 'package:flutter/material.dart';
import '../../../models/product_detail.dart';
// import '../../../config/app_colors.dart'; // Có thể bỏ nếu không dùng màu từ file này

class ProductInfo extends StatelessWidget {
  final ProductDetail product;
  final double price;

  const ProductInfo({Key? key, required this.product, required this.price}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // --- PHẦN QUAN TRỌNG: TẠO MÀU NỀN GRADIENT ---
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft, // Bắt đầu từ bên trái
          end: Alignment.centerRight, // Kết thúc ở bên phải
          colors: [
            Color(0xFFE0F7FA), // Màu xanh rất nhạt (Cyan 50) - Giống ảnh bên trái
            Color(0xFFF1F8E9), // Màu xanh lá rất nhạt (Light Green 50) - Giống ảnh bên phải
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Căn chỉnh padding cho đẹp hơn
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng giá tiền và thông tin bán
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                product.formatCurrency(price),
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),

              // Giá gốc gạch ngang
              Text(
                  product.formatCurrency(price*2),
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough
                  )
              ),
              const SizedBox(width: 8),

              // Tag giảm giá (-50%)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF81C784), // Nền xanh lá nhạt
                  borderRadius: BorderRadius.circular(4), // Bo góc nhẹ
                ),
                child: const Text(
                  "-50%",
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),

              const Spacer(),

              // Đã bán + Icon tim
              // Row(
              //   children: [
              //     Text(
              //         "Đã bán ${product.soldCount ~/ 1000}k+",
              //         style: const TextStyle(color: Colors.black54, fontSize: 12)
              //     ),
              //     const SizedBox(width: 8),
              //     // Nút tim tròn trắng mờ
              //     Container(
              //       padding: const EdgeInsets.all(6),
              //       decoration: BoxDecoration(
              //         color: Colors.white.withOpacity(0.6),
              //         shape: BoxShape.circle,
              //       ),
              //       child: const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
              //     )
              //   ],
              // ),
            ],
          ),

          const SizedBox(height: 12),

          // Tên sản phẩm
          Text(
            product.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Loại sản phẩm và đánh giá
          Row(
            children: [
              const Text("Giày thể thao", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Spacer(),
              const Icon(Icons.star, color: Colors.amber, size: 14),
              Text(
                  " ${product.rating} (${product.reviews.length} đánh giá)",
                  style: const TextStyle(color: Colors.grey, fontSize: 12)
              ),
            ],
          )
        ],
      ),
    );
  }
}