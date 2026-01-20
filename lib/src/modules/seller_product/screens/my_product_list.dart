import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/modules/seller_dashboard/models/shop_detail.dart';
import 'package:sneakerx/src/modules/seller_product/screens/product_addition.dart';
import 'package:sneakerx/src/modules/seller_product/widgets/product_list.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/api_response.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class ShopProductList extends StatefulWidget {
  const ShopProductList({super.key});

  @override
  State<ShopProductList> createState() => _ShopProductListState();
}

class _ShopProductListState extends State<ShopProductList> {
  final ShopService _shopService = ShopService();
  late Future<ApiResponse<ShopDetailResponse>> _shopsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, size: 20, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
                    (r) => false
            );
          },
        ),
        title: Text(
          'My Products',
          style: GoogleFonts.inter(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<ApiResponse<ShopDetailResponse>>(
        future: _shopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data?.data == null) {
            return const Center(child: Text("Shop not found"));
          }

          final data = snapshot.data!.data!;
          final products = data.products;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No products yet",
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add your first product to start selling",
                    style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                onRefresh: _loadData,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Add Product", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateProductScreen()),
          );
          if (result == true) {
            _loadData();
          }
        },
      ),
    );
  }
}