import 'package:flutter/material.dart';
import 'package:snkrxx/widgets/product_list.dart';
import 'package:snkrxx/widgets/icon_button_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snkrxx/data/mock_product_data.dart';
import 'package:go_router/go_router.dart';

class ShopProductList extends StatefulWidget {
  const ShopProductList({Key? key}) : super(key: key);

  @override
  State<ShopProductList> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopProductList> {
  String _activeTab = 'products';

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,

        leading: IconButtonWidget(
          icon: Icons.arrow_back,
          onPressed: () => context.go('/'),
        ),
        title:
        Text(
          'Sản phẩm của tôi',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButtonWidget(
            icon: Icons.help_outline,
            onPressed: () => _showMessage('Help clicked'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          // Product list
          Expanded(
            child: ListView.builder(
              itemCount: MockProductData.products.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: MockProductData.products[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}