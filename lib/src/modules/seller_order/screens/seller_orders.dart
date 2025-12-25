import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/models/order_item.dart';
import 'package:sneakerx/src/modules/seller_dashboard/widgets/icon_button_widget.dart';
import 'package:sneakerx/src/modules/seller_order/widgets/order_card.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class SellerOrders extends StatefulWidget {
  const SellerOrders({Key? key}) : super(key: key);

  @override
  State<SellerOrders> createState() => _SellerOrders();
}

class _SellerOrders extends State<SellerOrders> {
  final ShopService _shopService = ShopService();

  late Future<List<OrderItem>?> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = _loadData();
  }

  // Helper to load/reload data
  Future<List<OrderItem>?> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return _shopService.gettShopOrderItems(auth.shopId!);
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
        elevation: 2,

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
          'Theo dõi đơn hàng',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
      ),
      body: FutureBuilder<List<OrderItem>?>(
        future: _futureOrders,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Orders not found"));
          }

          final orders = snapshot.data!;

          return orders.isNotEmpty
              ? Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
            child:
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          return OrderCard(
                            order: orders[index],
                          );
                        },
                      )
                  ),
                ],
              ),
            ),
          )
              : SafeArea(
            child: Column(
              children: [
                // 1. Icon & Thông báo trống
                Container(
                  height: 300,
                  width: double.infinity,
                  color: const Color(0xFFF5F5F5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/empty_order.png"),
                              // Nếu chưa có ảnh, dùng Icon thay thế:
                              // icon: Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[300]),
                            )
                        ),
                        child: Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]), // Icon thay thế
                      ),
                      const SizedBox(height: 20),
                      Text("Bạn chưa có đơn hàng nào cả", style: TextStyle(color: Colors.black54, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      )
    );
  }

}
