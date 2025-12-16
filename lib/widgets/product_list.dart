import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snkrxx/data/mock_data.dart';
import 'package:snkrxx/data/mock_product_data.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

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
          Container(
            height: 60,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(product.image),
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
                _text('Giá: ${product.price}'),
                _text('Đã bán: ${product.sold}'),
              ],
            ),
          ),
          Icon(
            Icons.arrow_outward,
            color: Color(0xff86f4b5),
            size: 48, ),
        ],
      ),
    );
  }
  Widget _text(String text) {
    return Text(
      text,
      style: GoogleFonts.robotoMono(
        color: Colors.grey[300],
        fontSize: 14,
      ),
    );
  }
}