import 'package:flutter/material.dart';
import 'package:sneakerx/src/modules/product_detail/models/product_detail.dart';
import 'package:sneakerx/src/modules/product_detail/models/product_variant.dart';
import 'package:sneakerx/src/modules/product_detail/services/product_service.dart';
import '../../../config/app_colors.dart';
import '../widgets/product_header.dart';
import '../widgets/product_info.dart';
import '../widgets/product_selector.dart';
import '../widgets/info_accordion.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/related_products.dart';
import '../../cart/view/cart_view.dart';

class ProductDetailView extends StatefulWidget {
  final int productId;
  const ProductDetailView({super.key, required this.productId});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final ProductService _productService = ProductService();
  late Future<ProductDetail?> _productFuture;

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
      backgroundColor: AppColors.background,
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
              onPressed: () {},
            ),
          ),
        ],
      ),

      body: FutureBuilder<ProductDetail?>(
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
                  content: "⭐️ 4.8/5 (1034 đánh giá)\n\nUser1: Giày đẹp, êm chân, giao hàng nhanh.\nUser2: Đúng mô tả, shop tư vấn nhiệt tình.\nUser3: Hơi rộng một chút nhưng đi tất dày vào là vừa.",
                ),

                // Danh sách sản phẩm khác
                // RelatedProducts(products: relatedProducts),

                // Khoảng trống dưới cùng
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      )
      // bottomNavigationBar: BottomActionBar(
      //   product: product,
      //   variants: variants,
      //   images: images,
      // ),
    );
  }

  // // --- HÀM XỬ LÝ CHUYỂN TRANG GIỎ HÀNG ---
  // void _navigateToCart(BuildContext context) {
  //   // Tạo dữ liệu giả lập giỏ hàng dựa trên sản phẩm hiện tại
  //   final List<CartItemModel> fakeCartData = [
  //     CartItemModel(
  //       name: product.name,
  //       price: product.price,
  //       imageUrl: images.isNotEmpty ? images[0].imageUrl : "", // Lấy ảnh đầu tiên
  //       size: "42",
  //       colorName: "Cam/Đen",
  //       quantity: 1,
  //     ),
  //     // Thêm thử 1 sản phẩm gợi ý vào giỏ
  //     if (relatedProducts.isNotEmpty)
  //       CartItemModel(
  //         name: relatedProducts[0].name,
  //         price: relatedProducts[0].price,
  //         imageUrl: relatedProducts[0].imageUrl,
  //         size: "40",
  //         colorName: "Mặc định",
  //         quantity: 2,
  //       ),
  //   ];
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => CartView(cartItems: fakeCartData),
  //     ),
  //   );
}