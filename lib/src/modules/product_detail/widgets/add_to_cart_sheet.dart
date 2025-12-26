import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/cart/dtos/save_to_cart_request.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/cart_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';
import '../../../config/app_config.dart';

class AddToCartSheet extends StatefulWidget {
  final Product product;
  final bool isBuyNow;

  const AddToCartSheet({
    super.key,
    required this.product,
    this.isBuyNow = false,
  });

  @override
  State<AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<AddToCartSheet> {
  final CartService _cartService = CartService();

  int _quantity = 1;
  String _selectedSize = "";
  String _selectedColor = "";

  bool _isLoading = false;

  late Set<String> _sizes;
  late Set<String> _colors;

  @override
  void initState() {
    super.initState();
    _sizes = widget.product.variants.where((v) => v.variantType == 'SIZE').map((v) => v.variantValue).toSet();
    _colors = widget.product.variants.where((v) => v.variantType == 'COLOR').map((v) => v.variantValue).toSet();

    if (_sizes.isNotEmpty) _selectedSize = _sizes.first;
    if (_colors.isNotEmpty) _selectedColor = _colors.first;
  }

  Future<bool> _handleBtn() async {
    try {
      int sizeId = widget.product.variants.where((map) => map.variantValue.toString() == _selectedSize && map.variantType == "SIZE").first.variantId;
      int colorId = widget.product.variants.where((map) => map.variantValue.toString() == _selectedColor && map.variantType == "COLOR").first.variantId;

      SaveToCartRequest request = SaveToCartRequest(
          sizeId: sizeId,
          colorId: colorId,
          quantity: _quantity,
          productId: widget.product.productId
      );

      await _cartService.saveToCart(request);
      return true;
    } catch (e) {
      _showMessage("Error save to cart: $e");
      return false;
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
                    image: NetworkImage(widget.product.images.first.imageUrl),
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
                      Product.formatCurrency(widget.product.variants.first.price),
                      style: const TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    // Text("Kho: ${widget.product.}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    // const SizedBox(height: 4),
                    // Sửa hiển thị tên màu cho đẹp
                    Text(
                        "Đã chọn: ${AppConfig.getColorName(_selectedColor)}, Size $_selectedSize",
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
                                border: isSelected ? Border.all(color: AppConfig.primary, width: 2) : Border.all(color: Colors.grey[300]!),
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
                            color: isSelected ? AppConfig.primary.withOpacity(0.1) : Colors.white,
                            border: Border.all(
                                color: isSelected ? AppConfig.primary : Colors.grey[300]!
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              color: isSelected ? AppConfig.primary : Colors.black,
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
                backgroundColor: widget.isBuyNow ? AppConfig.primary : AppConfig.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),

              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                if(auth.isGuest) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 2,))
                  );
                } else {
                  setState(() => _isLoading = true);

                  final result = await _handleBtn();

                  setState(() => _isLoading = false);

                  Navigator.pop(context); // Đóng popup trước

                  if (result) {
                    if (widget.isBuyNow) {
                      // === TRƯỜNG HỢP MUA NGAY: CHUYỂN SANG GIỎ HÀNG ===
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(initialIndex: 2,),
                        ),
                      );
                    } else {
                      // === TRƯỜNG HỢP THÊM VÀO GIỎ: HIỆN THÔNG BÁO ===
                      _showMessage(
                          "Đã thêm: ${AppConfig.getColorName(_selectedColor)} - Size $_selectedSize (x$_quantity)");
                    }
                  } else {
                    _showMessage("Error save to cart");
                  }
                }
              },
              child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white,),)
                : Text(
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}