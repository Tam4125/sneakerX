// File: src/modules/product_detail/widgets/product_selector.dart
import 'package:flutter/material.dart';
import '../../../data/models/product_variant.dart';
import '../../../config/app_colors.dart';

// Đổi thành StatefulWidget để lưu trạng thái (Size đang chọn, Số lượng...)
class ProductSelector extends StatefulWidget {
  final List<ProductVariant> variants;

  const ProductSelector({Key? key, required this.variants}) : super(key: key);

  @override
  State<ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends State<ProductSelector> {
  // Biến lưu trạng thái tạm thời
  int _quantity = 1;
  String _selectedSize = "";
  String _selectedColor = "";

  // Lấy danh sách options từ variants
  late Set<String> _sizes;
  late Set<String> _colors;

  @override
  void initState() {
    super.initState();
    // Lọc data và chọn mặc định cái đầu tiên
    _sizes = widget.variants.where((v) => v.variantType == 'size').map((v) => v.variantValue).toSet();
    _colors = widget.variants.where((v) => v.variantType == 'color').map((v) => v.variantValue).toSet();

    if (_sizes.isNotEmpty) _selectedSize = _sizes.first;
    if (_colors.isNotEmpty) _selectedColor = _colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SỐ LƯỢNG ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Chọn số lượng", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(children: [
                _qtyBtn("-", () {
                  if (_quantity > 1) setState(() => _quantity--);
                }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text("$_quantity", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                _qtyBtn("+", () {
                  setState(() => _quantity++);
                }, isGreen: true),
              ]),
            ],
          ),

          const SizedBox(height: 12),

          // --- MÀU SẮC ---
          const Text("Màu sắc", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: _colors.map((c) {
              bool isSelected = _selectedColor == c;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(2), // Viền
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Color(int.parse(c)),
                    radius: 14,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // --- SIZE ---
          const Text("Size", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: _sizes.map((s) {
              bool isSelected = _selectedSize == s;
              return ChoiceChip(
                label: Text(s),
                selected: isSelected,
                selectedColor: AppColors.primary, // Màu khi chọn
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                ),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4)
                ),
                onSelected: (bool selected) {
                  setState(() => _selectedSize = s);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget nút tăng giảm
  Widget _qtyBtn(String text, VoidCallback onTap, {bool isGreen = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: isGreen ? AppColors.primary : Colors.grey[200],
            borderRadius: BorderRadius.circular(4)
        ),
        child: Text(text, style: TextStyle(color: isGreen ? Colors.white : Colors.black, fontSize: 18)),
      ),
    );
  }
}