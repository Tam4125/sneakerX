import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snkrxx/models/product.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String? thumbnailUrl;

  const ProductCard({
    super.key,
    required this.product,
    this.thumbnailUrl,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Product image (placeholder for now)
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: thumbnailUrl != null
                    ? FileImage(File(thumbnailUrl!))
                    : const AssetImage('assets/images/placeholder.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _text(product.name),
                _text('Giá: ${product.price.toStringAsFixed(0)}đ',),
                _text('Đã bán: ${product.soldCount}'),
                _text('Kho: ${product.stock}'),
                _text('Đánh giá: ${product.rating}'),
                _text('Trạng thái: ${product.status}'),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xff86f4b5)),
            onPressed: () {
              context.go(
                '/prodedit/${product.shopId}/${product.productId}',
              );
            },
          ),

        ],
      ),
    );
  }

  Widget _text(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.grey[300],
        fontSize: 11,
      ),
    );
  }
}
