import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/models/shops.dart';
import 'package:sneakerx/src/modules/seller_dashboard/widgets/icon_button_widget.dart';
import 'package:sneakerx/src/modules/seller_product/screens/product_addition.dart';
import 'package:sneakerx/src/modules/seller_product/widgets/product_list.dart';
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
    _loadData();
  }

  // REFRESH LOGIC: Simply re-assigning the Future triggers the FutureBuilder
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false
            );
          },
        ),
        title: Text(
          'Sản phẩm của tôi',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
      ),
      // Use FutureBuilder directly. No need for manual _isLoading flag.
      body: FutureBuilder<Shop?>(
        future: _shopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Shop not found"));
          }

          // Safe access to products
          final items = snapshot.data?.products ?? [];

          if (items.isEmpty) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    const Text("Bạn chưa có sản phẩm nào cả", style: TextStyle(color: Colors.black54, fontSize: 16)),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Space for FAB
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: items[index],
                  onRefresh: _loadData, // Pass refresh callback for delete/edit actions
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff464646),
        child: const Icon(Icons.add, color: Color(0xff86f4b5), size: 35),
        onPressed: () async {
          // 1. Wait for Add Screen result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );

          // 2. Refresh only if result is true
          if (result == true) {
            _loadData();
          }
        },
      ),
    );
  }
}