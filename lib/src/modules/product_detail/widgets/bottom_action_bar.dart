import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../data/models/product.dart';
import '../../../data/models/product_variant.dart';
import '../../../data/models/product_image.dart';
import 'add_to_cart_sheet.dart'; // Import file vừa tạo

class BottomActionBar extends StatefulWidget {
  // Cần nhận data để truyền vào Sheet
  final Product product;
  final List<ProductVariant> variants;
  final List<ProductImage> images;

  const BottomActionBar({
    Key? key,
    required this.product,
    required this.variants,
    required this.images,
  }) : super(key: key);

  @override
  State<BottomActionBar> createState() => _BottomActionBarState();
}

class _BottomActionBarState extends State<BottomActionBar> {
  bool _isFavorite = false;

  // Hàm hiển thị Bottom Sheet
  void _showAddToCartSheet(BuildContext context, {required bool isBuyNow}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép popup cao hơn 50% màn hình
      backgroundColor: Colors.transparent, // Để thấy bo tròn góc
      barrierColor: Colors.black.withOpacity(0.5), // Làm mờ nền đen 50%
      builder: (context) {
        return AddToCartSheet(
          product: widget.product,
          variants: widget.variants,
          images: widget.images,
          isBuyNow: isBuyNow,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))]
      ),
      child: Row(
        children: [
          // Nút Tim (Giữ nguyên)
          InkWell(
            onTap: () => setState(() => _isFavorite = !_isFavorite),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: _isFavorite ? Colors.red : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.white : Colors.grey,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Nút Thêm Giỏ -> Gọi hàm hiển thị Sheet (False)
          Expanded(child: _buildButton("Thêm vào giỏ", AppColors.secondary, () {
            _showAddToCartSheet(context, isBuyNow: false);
          })),

          const SizedBox(width: 10),

          // Nút Mua Ngay -> Gọi hàm hiển thị Sheet (True)
          Expanded(child: _buildButton("Mua ngay", AppColors.primary, () {
            _showAddToCartSheet(context, isBuyNow: true);
          })),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}