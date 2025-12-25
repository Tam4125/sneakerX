import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/models/enums/order_status.dart';
import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/seller_dashboard/models/shop_stats.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

// --- MAIN DASHBOARD SCREEN ---
class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final ShopService _shopService = ShopService();
  late Future<ShopStats?> _futureShopStats;

  @override
  void initState() {
    super.initState();
    _futureShopStats = _initSellerDashboardData();
  }

  Future<ShopStats?> _initSellerDashboardData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final shop = await _shopService.getCurrentUserShop();
      if (shop == null) {
        _showMessage("Get shop information failed");
        return null;
      }

      // Ensure shopId is not null
      if (auth.shopId == null) {
        return null;
      }

      final orders = await _shopService.gettShopOrders(auth.shopId!);
      if (orders == null) {
        _showMessage("Get shop orders failed");
        return null;
      }

      return ShopStats(shop: shop, orders: orders);
    } catch (e) {
      _showMessage("Get Seller dashboard information failed: $e");
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // Use Shop Logo or Placeholder
            FutureBuilder<ShopStats?>(
                future: _futureShopStats,
                builder: (context, snapshot) {
                  String logoUrl = "https://i.pravatar.cc/150?img=33";
                  if(snapshot.hasData && snapshot.data?.shop.shopLogo != null) {
                    logoUrl = snapshot.data!.shop.shopLogo;
                  }
                  return CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(logoUrl),
                  );
                }
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Xin chào,", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
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
      ),
      body: FutureBuilder<ShopStats?>(
        future: _futureShopStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Không thể tải dữ liệu Dashboard"));
          }

          final shopStats = snapshot.data!;
          final shop = shopStats.shop;
          final orders = shopStats.orders;

          // --- CALCULATE STATS ---
          // 1. Revenue (Sum of PAID or DELIVERED orders)
          double totalRevenue = orders
              .where((o) => o.orderStatus == OrderStatus.PAID || o.orderStatus == OrderStatus.DELIVERED)
              .fold(0, (sum, o) => sum + o.totalPrice);

          // 2. Order Counts
          int pendingCount = orders.where((o) => o.orderStatus == OrderStatus.PENDING || o.orderStatus == OrderStatus.SHIPPED).length;
          int cancelledCount = orders.where((o) => o.orderStatus == OrderStatus.CANCELLED).length;
          int deliveredCount = orders.where((o) => o.orderStatus == OrderStatus.DELIVERED).length;

          // 3. Sort Orders (Newest First) - Assuming orderId is incremental or you have createdAt
          // orders.sort((a, b) => b.orderId.compareTo(a.orderId));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. REVENUE CARD
                _buildRevenueCard(totalRevenue, shop.rating),

                const SizedBox(height: 24),

                // 2. ORDER STATUS GRID
                Text("Tình trạng đơn hàng", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildStatsGrid(pendingCount, cancelledCount, deliveredCount, shop.followersCount),

                const SizedBox(height: 24),

                // 3. RECENT ORDERS LIST
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Đơn hàng mới", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () {}, child: const Text("Xem tất cả")),
                  ],
                ),
                _buildRecentOrdersList(orders, shop.shopId),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildRevenueCard(double revenue, double rating) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark card theme
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.monetization_on_outlined, size: 150, color: Colors.white.withOpacity(0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tổng doanh thu", style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14)),
              const SizedBox(height: 8),
              Text(
                Product.formatCurrency(revenue),
                style: GoogleFonts.anton(color: Colors.white, fontSize: 42, letterSpacing: 1),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildMiniStat("Đánh giá", "$rating ⭐", Colors.yellow),
                  const SizedBox(width: 20),
                  // Placeholder for views if not available in API
                  _buildMiniStat("Lượt xem", "--", Colors.blueAccent),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
        Text(value, style: GoogleFonts.inter(color: valueColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildStatsGrid(int pending, int cancelled, int returned, int followers) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("Chờ xác nhận", pending.toString(), Icons.hourglass_empty, Colors.orange),
        _buildStatCard("Đơn hủy", cancelled.toString(), Icons.cancel_outlined, Colors.red),
        // If you don't track returns, you can change this to "Hoàn thành" or other stat
        _buildStatCard("Trả hàng", returned.toString(), Icons.assignment_return_outlined, Colors.purple),
        _buildStatCard("Người theo dõi", followers.toString(), Icons.person_add_alt, const Color(0xFF86F4B5)),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(count, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(title, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersList(List<Order> orders, int shopId) {
    // Show only top 5 orders
    final recentOrders = orders.take(5).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentOrders.length,
      itemBuilder: (context, index) {
        final order = recentOrders[index];

        // Find the product name for this shop (assuming 1 item per shop-order split, or pick first)
        String productName = "Sản phẩm";
        try {
          final item = order.orderItems.firstWhere((i) => i.shopId == shopId);
          productName = item.product.name; // Assuming OrderItem -> Product -> name
        } catch(e) {
          productName = "Order #${order.orderId}";
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
                child: const Icon(Icons.shopping_bag_outlined, color: Colors.black54),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text("#${order.orderId}", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Product.formatCurrency(order.totalPrice), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF8B5FBF))),
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
    String text;
    Color color;

    switch (status) {
      case OrderStatus.PENDING:
        text = "Chờ xác nhận";
        color = Colors.orange;
        break;
      case OrderStatus.SHIPPED: // Assuming you have SHIPPED or similar
        text = "Đang giao";
        color = Colors.blue;
        break;
      case OrderStatus.DELIVERED:
      case OrderStatus.PAID:
        text = "Hoàn thành";
        color = Colors.green;
        break;
      case OrderStatus.CANCELLED:
        text = "Đã hủy";
        color = Colors.red;
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