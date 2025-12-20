import 'package:flutter/material.dart';
import 'package:snkrxx/widgets/product_list.dart';
import 'package:snkrxx/widgets/icon_button_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snkrxx/models/product.dart';
import 'package:go_router/go_router.dart';
import 'package:snkrxx/data/database_helper.dart';
import 'package:snkrxx/models/product_media.dart';

class ShopProductList extends StatefulWidget {
  final int shopId;

  const ShopProductList({Key? key, required this.shopId}) : super(key: key);

  @override
  State<ShopProductList> createState() => _ShopProductList();
}

class _ShopProductList extends State<ShopProductList> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = DatabaseHelper().getProductsByShopId(widget.shopId);
  }

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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper().getProductsWithMediaByShop(widget.shopId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final items = snapshot.data!;

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final product = items[index]['product'] as Product;
                    final media = items[index]['thumbnail'] as ProductMedia?;

                    return ProductCard(
                      product: product,
                      thumbnailUrl: media?.mediaUrl,
                    );

                  },
                );
              },
            )

          )

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/prodadd/1'),
        backgroundColor: Color(0xff464646),
        child: Icon(Icons.add,
        color: Color(0xff86f4b5),
          size: 35,
        ), // icon inside the button
      ),
    );
  }
}