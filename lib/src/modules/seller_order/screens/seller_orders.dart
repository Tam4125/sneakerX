import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/models/enums/order_status.dart';
import 'package:sneakerx/src/models/shop_order.dart';
import 'package:sneakerx/src/modules/seller_order/dtos/update_shop_order_request.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/order_service.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> with SingleTickerProviderStateMixin {
  final ShopService _shopService = ShopService();
  final OrderService _orderService = OrderService();
  late TabController _tabController;

  List<ShopOrder>? _allOrders;
  bool _isLoading = true;

  // Track which specific order is currently updating to show spinner only on that card
  int? _updatingOrderId;

  @override
  void initState() {
    super.initState();
    // Tabs: All, Pending, Shipped, Done (Delivered/Cancelled)
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await _shopService.getShopOrders();

      if (response.success && response.data != null) {
        setState(() {
          _allOrders = response.data!;
          // Sort by newest first
          _allOrders!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
      }
    } catch (e) {
      print("Error loading orders: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int shopOrderId, OrderStatus newStatus) async {
    setState(() => _updatingOrderId = shopOrderId);

    try {
      final request = UpdateShopOrderRequest(
          shopOrderId: shopOrderId,
          orderStatus: newStatus
      );

      final response = await _orderService.updateShopOrder(request);

      if (response.success) {
        GlobalSnackbar.show(context, success: true, message: "Order status updated to ${newStatus.name}");
        _loadData(); // Refresh list to move card to correct tab
      } else {
        GlobalSnackbar.show(context, success: false, message: response.message);
      }
    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: "Update failed: $e");
    } finally {
      if (mounted) setState(() => _updatingOrderId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Order Management', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black, size: 20),
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
                  (r) => false
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Pending"),
            Tab(text: "Shipped"), // Includes Confirmed & Shipped
            Tab(text: "History"), // Delivered & Cancelled
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _allOrders == null || _allOrders!.isEmpty
          ? _buildEmptyState()
          : TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(_allOrders!),
          _buildOrderList(_filterOrders([OrderStatus.PENDING])),
          _buildOrderList(_filterOrders([OrderStatus.CONFIRMED, OrderStatus.SHIPPED])),
          _buildOrderList(_filterOrders([OrderStatus.DELIVERED, OrderStatus.CANCELLED, OrderStatus.RETURNED])),
        ],
      ),
    );
  }

  List<ShopOrder> _filterOrders(List<OrderStatus> statuses) {
    if (_allOrders == null) return [];
    return _allOrders!.where((o) => statuses.contains(o.orderStatus)).toList();
  }

  Widget _buildOrderList(List<ShopOrder> orders) {
    if (orders.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.black,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (c, i) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(ShopOrder order) {
    bool isUpdatingThis = _updatingOrderId == order.shopOrderId;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // HEADER: Order ID & Status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order.shopOrderId}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                _buildStatusBadge(order.orderStatus),
              ],
            ),
          ),
          const Divider(height: 1),

          // ITEMS LIST
          ...order.orderItems.map((item) => Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                    image: item.product.images.isNotEmpty
                        ? DecorationImage(image: NetworkImage(item.product.images.first.imageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productNameSnapshot, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text("Variant: ${item.skuNameSnapshot}", style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("x${item.quantity}", style: GoogleFonts.inter(fontSize: 13)),
                          Text(AppConfig.formatCurrency(item.priceAtPurchase), style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )).toList(),

          Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NOTE :",
                    style: GoogleFonts.anton(fontSize: 18, color: Colors.amber),
                  ),
                  SizedBox(width: 5,),
                  Expanded(
                    child: Text(
                      order.noteToSeller,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
          ),

          const Divider(height: 1),


          // FOOTER: Total & Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Payment", style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12)),
                    Text(
                        AppConfig.formatCurrency(order.subTotal + order.shippingFee), // Assuming simple logic
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ACTION BUTTONS
                if (order.orderStatus != OrderStatus.DELIVERED && order.orderStatus != OrderStatus.CANCELLED)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUpdatingThis ? null : () => _handleActionTap(order),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12)
                      ),
                      child: isUpdatingThis
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_getNextActionLabel(order.orderStatus), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- LOGIC HELPERS ---

  String _getNextActionLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING: return "Confirm Order";
      case OrderStatus.CONFIRMED: return "Ship Order";
      case OrderStatus.SHIPPED: return "Mark Delivered";
      default: return "View Details";
    }
  }

  void _handleActionTap(ShopOrder order) {
    OrderStatus? nextStatus;
    if (order.orderStatus == OrderStatus.PENDING) nextStatus = OrderStatus.CONFIRMED;
    else if (order.orderStatus == OrderStatus.CONFIRMED) nextStatus = OrderStatus.SHIPPED;
    else if (order.orderStatus == OrderStatus.SHIPPED) nextStatus = OrderStatus.DELIVERED;

    if (nextStatus != null) {
      _updateStatus(order.shopOrderId, nextStatus);
    }
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String text = status.name;

    switch (status) {
      case OrderStatus.PENDING: color = Colors.orange; break;
      case OrderStatus.CONFIRMED: color = Colors.blue; break;
      case OrderStatus.SHIPPED: color = Colors.purple; break;
      case OrderStatus.DELIVERED: color = Colors.green; break;
      case OrderStatus.CANCELLED: color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No orders yet", style: GoogleFonts.inter(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}