import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/seller_product/screens/product_edit.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onRefresh;

  const ProductCard({
    super.key,
    required this.product,
    required this.onRefresh
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditProductScreen(productId: product.productId)
                )
            );
            if (result == true) {
              onRefresh();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 90,
                    width: 90,
                    color: Colors.grey[100],
                    child: product.images.isNotEmpty
                        ? Image.network(
                      product.images.first.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, color: Colors.grey);
                      },
                    )
                        : Image.network(AppConfig.baseImageUrl, fit: BoxFit.cover),
                  ),
                ),

                const SizedBox(width: 16),

                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProductScreen(productId: product.productId)
                                  )
                              );
                              if (result == true) {
                                onRefresh();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 8),
                              child: Icon(Icons.edit_outlined, size: 20, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        AppConfig.formatCurrency(product.basePrice), // Ensure you use your currency formatter
                        style: GoogleFonts.inter(
                          color: Colors.green[700],
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Stats Row
                      Row(
                        children: [
                          _buildStatBadge(Icons.shopping_bag_outlined, "${product.soldCount} Sold"),
                          const SizedBox(width: 12),
                          _buildStatBadge(Icons.star_border, "${product.rating} Rating"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}