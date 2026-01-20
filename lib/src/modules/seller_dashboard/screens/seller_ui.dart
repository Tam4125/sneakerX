import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/models/enums/order_status.dart';
import 'package:sneakerx/src/models/shop_order.dart';
import 'package:sneakerx/src/models/shops.dart';
import 'package:sneakerx/src/modules/seller_dashboard/models/shop_detail.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/screens/seller_main_screen.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/api_response.dart';


class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final ShopService _shopService = ShopService();
  late Future<ApiResponse<ShopDetailResponse>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _shopService.getCurrentUserShop();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<ShopDetailResponse>>(
      future: _detailFuture,
      builder: (context, snapshot) {

        // --- LOADING STATE ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // --- ERROR STATE ---
        else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        // --- EMPTY DATA STATE ---
        else if (!snapshot.hasData || snapshot.data?.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Shop Dashboard")),
            body: const Center(child: Text("Unable to load Shop Data")),
          );
        }

        // --- SUCCESS STATE: Extract Data ---
        final data = snapshot.data!.data!;
        final shop = data.shop;
        final orders = data.shopOrders;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),

          appBar: _buildAppBar(shop),

          body: _buildDashboardBody(shop, orders),
        );
      },
    );
  }

  // Updated AppBar to accept Shop data
  AppBar _buildAppBar(Shop shop) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.home),
        onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0,)));},
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            // 3. Use the real logo or a fallback
            backgroundImage: (shop.shopLogo.isNotEmpty)
                ? NetworkImage(shop.shopLogo)
                : NetworkImage(AppConfig.baseAvatartUrl),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Shop Dashboard", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              Text(shop.shopName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
          onPressed: () {},
        )
      ],
    );
  }
  // Moved the body logic to a separate helper function for cleanliness
  Widget _buildDashboardBody(Shop shop, List<ShopOrder> orders) {
    // --- 1. CALCULATE STATS ---
    double totalRevenue = orders
        .where((o) => o.orderStatus == OrderStatus.DELIVERED)
        .fold(0.0, (sum, o) => sum + o.subTotal);

    int processingCount = orders.where((o) =>
    o.orderStatus == OrderStatus.PENDING ||
        o.orderStatus == OrderStatus.CONFIRMED // Assuming CONFIRMED exists
    ).length;

    int cancelledCount = orders.where((o) => o.orderStatus == OrderStatus.CANCELLED).length;
    int returnCount = orders.where((o) => o.orderStatus == OrderStatus.RETURNED).length;

    // Sort orders by date (Newest first)
    // Create a new list to sort so we don't mutate the original snapshot data strictly
    List<ShopOrder> sortedOrders = List.from(orders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return SingleChildScrollView(
      child: Column(
        children: [
          DashboardCard(
            onTap: () {},
            processingCount: processingCount.toString(),
            canceledCount: cancelledCount.toString(),
            returnedCount: returnCount.toString(),
            reviewCount: shop.rating.toStringAsFixed(1),
            totalRevenue: AppConfig.formatCurrency(totalRevenue), // Use formatter here
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "New Orders",
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                    onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SellerMainScreen(initialIndex: 2,)));},
                    child: const Text("All Orders")
                ),
              ],
            ),
          ),

          _buildRecentOrdersList(sortedOrders),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersList(List<ShopOrder> orders) {
    if (orders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text("No Orders yet"),
      );
    }

    // Take top 5
    final recentOrders = orders.take(5).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recentOrders.length,
      itemBuilder: (context, index) {
        final order = recentOrders[index];

        // Product Name Logic (Get first item name)
        String productName = "Product";
        if (order.orderItems.isNotEmpty) {
          productName = order.orderItems[0].productNameSnapshot; // Uncomment if model supports
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory, color: Colors.black54),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)
                    ),
                    const SizedBox(height: 4),
                    Text(
                        "ID: ${order.shopOrderId}",
                        style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)
                    ),
                    Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                        style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 10)
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      AppConfig.formatCurrency(order.subTotal), // Using subTotal from ShopOrder
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF8B5FBF))
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(order.orderStatus),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.PENDING:
        text = "Pending";
        color = Colors.orange;
        break;
      case OrderStatus.CONFIRMED:
        text = "Awaiting Pickup";
        color = Colors.yellow;
        break;
      case OrderStatus.SHIPPED:
        text = "Awaiting Delivery";
        color = Colors.blue;
        break;
      case OrderStatus.DELIVERED:
        text = "Delivered";
        color = Colors.green;
        break;
      case OrderStatus.CANCELLED:
        text = "Canceled";
        color = Colors.red;
        break;
      case OrderStatus.RETURNED:
        text = "Returned";
        color = Colors.purple;
        break;
      default:
        text = status.name;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}


class DashboardCard extends StatelessWidget {
  final VoidCallback onTap;
  final String processingCount;
  final String canceledCount;
  final String returnedCount;
  final String reviewCount;
  final String totalRevenue;

  const DashboardCard({
    super.key,
    required this.onTap,
    required this.processingCount,
    required this.canceledCount,
    required this.returnedCount,
    required this.reviewCount,
    this.totalRevenue = "\$0.00", // Default
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), // Using dark background per your design
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0,5))
            ]
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Stats Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Processing Orders:', processingCount),
                    _buildStatItem('Canceled Orders:', canceledCount),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Returned Orders:', canceledCount),
                    _buildStatItem('Rate:', reviewCount),
                  ],
                ),

                const SizedBox(height: 30),

                // Big Revenue Text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Revenue",
                      style: GoogleFonts.anton(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalRevenue.isNotEmpty ? totalRevenue : "\$0.00",
                      style: GoogleFonts.inter(
                        color: const Color(0xff86f4b5), // Green accent
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.robotoMono(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}