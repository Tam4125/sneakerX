import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../data/models/product_variant.dart';
import '../../../data/models/product_image.dart';
import '../../../config/app_colors.dart';

// --- 1. THÊM IMPORT TRANG CART ---
import '../../cart/view/cart_view.dart';

class AddToCartSheet extends StatefulWidget {
  final Product product;
  final List<ProductVariant> variants;
  final List<ProductImage> images;
  final bool isBuyNow;

  const AddToCartSheet({
    Key? key,
    required this.product,
    required this.variants,
    required this.images,
    this.isBuyNow = false,
  }) : super(key: key);

  @override
  State<AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<AddToCartSheet> {
  int _quantity = 1;
  String _selectedSize = "";
  String _selectedColor = "";

  late Set<String> _sizes;
  late Set<String> _colors;

  @override
  void initState() {
    super.initState();
    _sizes = widget.variants.where((v) => v.variantType == 'size').map((v) => v.variantValue).toSet();
    _colors = widget.variants.where((v) => v.variantType == 'color').map((v) => v.variantValue).toSet();

    if (_sizes.isNotEmpty) _selectedSize = _sizes.first;
    if (_colors.isNotEmpty) _selectedColor = _colors.first;
  }

  // --- 2. THÊM HÀM DỊCH TÊN MÀU ---
  String _getColorName(String hexCode) {
    switch (hexCode) {
      case "0xFFFF0000": return "Đỏ";
      case "0xFF0000FF": return "Xanh Dương";
      case "0xFFFFFF00": return "Vàng";
      case "0xFF000000": return "Đen";
      case "0xFF808080": return "Xám";
      case "0xFF8E44AD": return "Tím";
      default: return "Màu khác";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(widget.images.first.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      widget.product.formattedPrice,
                      style: const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text("Kho: ${widget.product.stock}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    // Sửa hiển thị tên màu cho đẹp
                    Text(
                        "Đã chọn: ${_getColorName(_selectedColor)}, Size $_selectedSize",
                        style: const TextStyle(fontSize: 14, color: Colors.black87)
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),

          const Divider(height: 30),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Màu sắc", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: _colors.map((colorHex) {
                      bool isSelected = _selectedColor == colorHex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = colorHex),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: isSelected ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Container(
                                width: 30, height: 30,
                                color: Color(int.parse(colorHex)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  const Text("Size", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _sizes.map((s) {
                      bool isSelected = _selectedSize == s;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSize = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                            border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey[300]!
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Số lượng", style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          _qtyButton("-", () {
                            if (_quantity > 1) setState(() => _quantity--);
                          }),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text("$_quantity", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          _qtyButton("+", () {
                            setState(() => _quantity++);
                          }),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isBuyNow ? AppColors.primary : AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),

              // --- 3. LOGIC CHUYỂN TRANG Ở ĐÂY ---
              onPressed: () {
                Navigator.pop(context); // Đóng popup trước

                if (widget.isBuyNow) {
                  // === TRƯỜNG HỢP MUA NGAY: CHUYỂN SANG GIỎ HÀNG ===

                  // Tạo dữ liệu sản phẩm để gửi đi
                  final itemToAdd = CartItemModel(
                    name: widget.product.name,
                    price: widget.product.price,
                    imageUrl: widget.images.isNotEmpty ? widget.images.first.imageUrl : "",
                    size: _selectedSize,
                    colorName: _getColorName(_selectedColor), // Dùng hàm đổi tên màu
                    quantity: _quantity,
                  );

                  // Chuyển trang
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartView(cartItems: [itemToAdd]),
                    ),
                  );
                } else {
                  // === TRƯỜNG HỢP THÊM VÀO GIỎ: HIỆN THÔNG BÁO ===
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Đã thêm: ${_getColorName(_selectedColor)} - Size $_selectedSize (x$_quantity)"))
                  );
                }
              },

              child: Text(
                widget.isBuyNow ? "Mua ngay" : "Thêm vào giỏ hàng",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _qtyButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text),
      ),
    );
  }
}