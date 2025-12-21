import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/seller/product/screens/product_edit.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });


  @override
  Widget build(BuildContext context) {

    final hasVariants = product.variants.isNotEmpty;
    final firstVariant = hasVariants ? product.variants.first : null;

    final price = hasVariants ? product.formatCurrency(firstVariant!.price) : 'Liên hệ';
    final stock = hasVariants ? firstVariant!.stock.toString() : '0';

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: product.images.isNotEmpty
                    ? NetworkImage(product.images.first.imageUrl)
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
                _text('Giá: $price'),
                _text('Đã bán: ${product.soldCount}'),
                _text('Kho: $stock'),
                _text('Đánh giá: ${product.rating}'),
                _text('Đã bán: ${product.soldCount}'),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xff86f4b5)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProductScreen(product: product)
                )
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
