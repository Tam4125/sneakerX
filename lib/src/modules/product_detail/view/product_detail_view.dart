import 'package:flutter/material.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/models/product_variant.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/product_service.dart';
import '../../../config/app_config.dart';
import '../widgets/product_header.dart';
import '../widgets/product_info.dart';
import '../widgets/product_selector.dart';
import '../widgets/info_accordion.dart';
import '../widgets/bottom_action_bar.dart';

class ProductDetailView extends StatefulWidget {
  final int productId;
  const ProductDetailView({super.key, required this.productId});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final ProductService _productService = ProductService();
  late Future<Product?> _productFuture;

  // State to track selected variant (for price calculation)
  ProductVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.background,
      extendBodyBehindAppBar: true, // Cho phép ảnh tràn lên dưới thanh status bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Trong suốt
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 8, top: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8), // Nền trắng mờ để dễ nhìn nút back
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8), // Nền trắng mờ
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(initialIndex: 3,)
                  )
                );
              },
            ),
          ),
        ],
      ),

      body: FutureBuilder<Product?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Product not found"));
          }

          final product = snapshot.data!;
          final images = product.images;
          final variants = product.variants;
          final currentVariant = _selectedVariant ?? (variants.isNotEmpty ? variants.first : null);

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductHeader(images: images),
                ProductInfo(product: product, price: currentVariant!.price,),
                ProductSelector(variants: variants),

                const SizedBox(height: 8),

                // Các mục thông tin mở rộng
                InfoAccordion(
                  title: "Hướng dẫn chọn size",
                  content: "Để chọn size chuẩn, vui lòng đo chiều dài bàn chân từ gót đến ngón cái:\n- Chân 23cm: Size 37\n- Chân 23.5cm: Size 38\n- Chân 24cm: Size 39\n- Chân 25cm: Size 40\nNếu chân bè ngang, bạn nên tăng thêm 1 size để thoải mái hơn.",
                ),
                InfoAccordion(
                  title: "Thông số và mô tả",
                  content: product.description,
                ),
                InfoAccordion(
                  title: "Chăm sóc",
                  content: "- Không giặt giày bằng máy giặt.\n- Tránh phơi trực tiếp dưới ánh nắng gắt.\n- Nên dùng khăn ẩm hoặc dung dịch vệ sinh giày chuyên dụng để lau vết bẩn.\n- Giữ giày ở nơi khô thoáng để tránh ẩm mốc.",
                ),
                InfoAccordion(
                  title: "Đánh giá sản phẩm",
                  content: "⭐️ ${product.rating}/5.0 (${product.reviews.length} đánh giá)",
                ),

                // Khoảng trống dưới cùng
                const SizedBox(height: 20),
                BottomActionBar(product: product),
                const SizedBox(height: 50,)
              ],
            ),
          );
        },
      )
    );
  }
}