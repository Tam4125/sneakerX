import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/models/enums/order_status.dart';
import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/models/order_item.dart';
import 'package:sneakerx/src/models/shop_order.dart';
import 'package:sneakerx/src/modules/profile/widgets/rating_sheets.dart';
import 'package:sneakerx/src/services/order_service.dart';
import 'package:sneakerx/src/services/user_service.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class OrderHistoryView extends StatefulWidget {
  final int initialIndex;

  const OrderHistoryView({super.key, this.initialIndex = 0});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final OrderService _orderService = OrderService();

  late TabController _tabController;
  late Future<ApiResponse<List<Order>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: widget.initialIndex);
    _ordersFuture = _userService.getOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _userService.getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppConfig.secondary200),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("My Orders", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.search, color: AppConfig.secondary200), onPressed: () {}),
          IconButton(icon: Icon(Icons.chat_bubble_outline, color: AppConfig.secondary200), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppConfig.secondary200,
          unselectedLabelColor: Colors.black54,
          indicatorColor: AppConfig.secondary200,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Awaiting Pickup"),
            Tab(text: "Awaiting Delivery"),
            Tab(text: "Delivered"),
            Tab(text: "Returned"),
            Tab(text: "Canceled"),
          ],
        ),
      ),
      body: FutureBuilder<ApiResponse<List<Order>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black,));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data?.data == null) {
            return const Center(child: Text("No orders found"));
          }

          List<Order> orders = snapshot.data!.data!;
          List<ShopOrder> shopOrders = [];
          for(var order in orders) {
            shopOrders.addAll(order.shopOrders);
          }

          List<ShopOrder> pendingOrders = shopOrders.where((shopOrder) => shopOrder.orderStatus == OrderStatus.PENDING).toList();
          List<ShopOrder> awaitingPickupOrders = shopOrders.where((shopOrder) => shopOrder.orderStatus == OrderStatus.CONFIRMED).toList();
          List<ShopOrder> shippingOrders = shopOrders.where((shopOrder) => shopOrder.orderStatus == OrderStatus.SHIPPED).toList();
          List<ShopOrder> deliveredOrders = shopOrders.where((shopOrder) => shopOrder.orderStatus == OrderStatus.DELIVERED).toList();
          List<ShopOrder> returnedOrders = shopOrders.where((shopOrder) => shopOrder.orderStatus == OrderStatus.RETURNED).toList();
          List<ShopOrder> canceledOrders = shopOrders.where((shopOrder) => shopOrder.orderStatus == OrderStatus.CANCELLED).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(pendingOrders),
              _buildTabContent(awaitingPickupOrders),
              _buildTabContent(shippingOrders),
              _buildTabContent(deliveredOrders),
              _buildTabContent(returnedOrders),
              _buildTabContent(canceledOrders),
            ],
          );
        }
      )
    );
  }


  Widget _buildTabContent(List<ShopOrder> shopOrders) {
    if (shopOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("No orders yet", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: shopOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildShopOrderCard(shopOrders[index]),
    );
  }

  // --- ORDER CARD (The Single Shop Package) ---
  Widget _buildShopOrderCard(ShopOrder shopOrder) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0,2))
          ]
      ),
      child: Column(
        children: [
          // 1. HEADER: Shop Name & Status
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.store, size: 18, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  shopOrder.shop.shopName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  _getStatusText(shopOrder.orderStatus),
                  style: const TextStyle(color: AppConfig.primary200, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // 2. ITEMS LIST
          ...shopOrder.orderItems.map((item) => _buildProductRow(item)),

          const Divider(height: 1, thickness: 0.5),

          // 3. FOOTER: Total & Buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Total: ", style: TextStyle(fontSize: 14)),
                    Text(
                      AppConfig.formatCurrency(shopOrder.subTotal + shopOrder.shippingFee),
                      style: const TextStyle(color: AppConfig.primary200, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ACTION BUTTONS (Dynamic based on status)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (shopOrder.orderStatus == OrderStatus.PENDING)
                      OutlinedButton(
                        onPressed: () => _showLogoutDialog(context, shopOrder.shopOrderId),
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            foregroundColor: Colors.black87
                        ),
                        child: const Text("Cancel"),
                      ),

                    if (shopOrder.orderStatus == OrderStatus.CONFIRMED || shopOrder.orderStatus == OrderStatus.SHIPPED)
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to Review Screen
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppConfig.primary200,
                            elevation: 0
                        ),
                        child: const Text("Location", style: TextStyle(color: Colors.black)),
                      ),

                    if (shopOrder.orderStatus == OrderStatus.DELIVERED)
                      ElevatedButton(
                        onPressed: () {
                          _showRatingBottomSheet(context, shopOrder.orderItems);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppConfig.primary200,
                            elevation: 0
                        ),
                        child: const Text("Rate", style: TextStyle(color: Colors.black)),
                      ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ITEM ROW ---
  Widget _buildProductRow(OrderItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[50], // Slightly different bg for items
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: item.product.images.isNotEmpty
                ? Image.network(item.product.images.first.imageUrl, fit: BoxFit.cover)
                : const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productNameSnapshot,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  "Variation: ${item.skuNameSnapshot}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("x${item.quantity}", style: const TextStyle(fontSize: 13)),
                    Text(
                      AppConfig.formatCurrency(item.priceAtPurchase), // Snapshot price
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, int shopOrderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to delete this order?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () async {
                try {
                  final result = await _orderService.deleteShopOrder(shopOrderId);
                  Navigator.pop(ctx);

                  if(result.success) {
                    GlobalSnackbar.show(context, success: true, message: result.message);
                    _refreshOrders();
                  } else {
                    GlobalSnackbar.show(context, success: false, message: result.message);
                  }
                } catch (e) {
                  GlobalSnackbar.show(context, success: false, message: "Service Error: Delete order failed {$e}");
                }
              },
              // Using primary Purple for confirm button
              child: Text("Delete",
                  style: TextStyle(
                      color: AppConfig.secondary100,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showRatingBottomSheet(BuildContext context, List<OrderItem> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Needed for full height behavior with keyboard
      backgroundColor: Colors.transparent,
      builder: (context) => RateProductSheet(items: items),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING: return "Pending";
      case OrderStatus.CONFIRMED: return "Awaiting Pickup";
      case OrderStatus.SHIPPED: return "Awaiting Delivery";
      case OrderStatus.DELIVERED: return "Delivered";
      case OrderStatus.CANCELLED: return "Cancelled";
      case OrderStatus.RETURNED: return "Returned";
      default: return "";
    }
  }
}