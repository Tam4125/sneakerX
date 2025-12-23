import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/models/shops.dart';
import 'package:sneakerx/src/modules/seller/product/screens/product_addition.dart';
import 'package:sneakerx/src/modules/seller/product/widgets/product_list.dart';
import 'package:sneakerx/src/modules/seller/widgets/seller/icon_button_widget.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class ShopProductList extends StatefulWidget {

  const ShopProductList({super.key});

  @override
  State<ShopProductList> createState() => _ShopProductList();
}

class _ShopProductList extends State<ShopProductList> {
  final ShopService _shopService = ShopService();
  late Future<Shop?> _shopsFuture;

  @override
  void initState() {
    super.initState();
    _loadData(); // Call the helper method
  }

  // Helper to load/reload data
  void _loadData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      if (auth.hasShop) {
        _shopsFuture = _shopService.getCurrentUserShop();
      } else {
        _shopsFuture = Future.error("No Shop Found");
      }
    });
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
          icon: Icons.home,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen()
              )
            );
          },
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
      body: FutureBuilder<Shop?>(
        future: _shopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Product not found"));
          }

          final items = snapshot.data!.products;

          return SafeArea(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final product = items[index];

                return ProductCard(product: product, onRefresh: _loadData,);
              },
            )
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Wait for "Add Screen" to return
          final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProductScreen())
          );

          // If added successfully, refresh the list
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: Color(0xff464646),
        child: Icon(Icons.add,
        color: Color(0xff86f4b5),
          size: 35,
        ), // icon inside the button
      ),
    );
  }
}