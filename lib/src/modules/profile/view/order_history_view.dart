import 'package:flutter/material.dart';
import 'package:sneakerx/src/models/enums/order_status.dart';
import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/profile/dtos/order_item_model.dart';
import 'package:sneakerx/src/services/order_service.dart';
import 'package:sneakerx/src/services/user_service.dart';

class OrderHistoryView extends StatefulWidget {
  final int initialIndex;

  const OrderHistoryView({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF8B5FBF); // Màu tím chủ đạo
  final UserService _userService = UserService();
  final OrderService _orderService = OrderService();

  late TabController _tabController;
  late Future<List<Order>?> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialIndex);
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
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Đơn đã mua", style: TextStyle(color: Colors.black87, fontSize: 18)),
        actions: [
          IconButton(icon: Icon(Icons.search, color: primaryColor), onPressed: () {}),
          IconButton(icon: Icon(Icons.chat_bubble_outline, color: primaryColor), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.black54,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: "Chờ xác nhận"),
            Tab(text: "Chờ giao hàng"),
            Tab(text: "Đã giao"),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black,));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Orders not found"));
          }

          List<Order> orders = snapshot.data!;

          List<Order> pendingOrders = orders.where((order) => order.orderStatus == OrderStatus.PENDING).toList();
          List<Order> shippedOrders = orders.where((order) => order.orderStatus == OrderStatus.SHIPPED || order.orderStatus == OrderStatus.PAID).toList();
          List<Order> delieveredOrders = orders.where((order) => order.orderStatus == OrderStatus.DELIVERED).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(pendingOrders),
              _buildTabContent(shippedOrders),
              _buildTabContent(delieveredOrders),
            ],
          );
        }
      )
    );
  }

  // Nội dung từng Tab
  Widget _buildTabContent(List<Order> orders) {

    // NẾU KHÔNG CÓ ĐƠN HÀNG -> HIỆN EMPTY STATE + GỢI Ý
    if (orders.isEmpty) {
      return SingleChildScrollView(
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
    }

    // NẾU CÓ ĐƠN HÀNG -> HIỆN LIST
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderItem(orders[index]),
    );
  }

  Widget _buildOrderItem(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      child: Column(
        children: [
          // --- 1. HEADER (Order ID) ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Đơn hàng #${order.orderId}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                // You can add status text here if you want
                Text(
                    _getStatusText(order.orderStatus),
                    style: TextStyle(color: primaryColor, fontSize: 13)
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // --- 2. LIST OF PRODUCTS (Loop) ---
          // We use the spread operator (...) to expand the list of widgets into the Column
          ...order.orderItems.map((item) {

            final orderItemModel = OrderItemModel.fromOrderItem(item);

            return Column(
              children: [
                _buildProductRow(orderItemModel), // Build the row for this specific item
                const Divider(height: 1, thickness: 0.5), // Separator between items
              ],
            );
          }).toList(),

          // --- 3. FOOTER (Total Money) ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Thành tiền: ", style: TextStyle(fontSize: 14)),
                Text(
                    Product.formatCurrency(order.totalPrice), // Assuming you have totalPrice in Order
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ],
            ),
          ),

          // --- 4. ACTION BUTTONS ---
          if (order.orderStatus == OrderStatus.PENDING)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        final result = await _orderService.deleteOrder(order.orderId);

                        if(result != null) {
                          _showMessage("Đã hủy đơn hàng: ${order.orderId}");
                          _refreshOrders();
                        }
                      } catch (e) {
                        _showMessage("Lỗi hủy đơn hàng: $e");
                      }
                    },
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300)),
                    child: const Text("Hủy đơn", style: TextStyle(color: Colors.black54)),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }


// --- HELPER WIDGET FOR SINGLE ITEM ---
  Widget _buildProductRow(OrderItemModel item) {
    // Access data safely based on your specific model structure
    // Assuming: OrderItem -> has 'productName', 'image', 'price', etc.
    // OR if you need to go deeper: item.cartItem.product.name

    // Example mapping (Adjust these fields to match your OrderItem model):
    final String name = item.productName; // or item.cartItem.product.name
    final String image = item.productImage; // or item.cartItem.product.images[0].url
    final String variant = "${item.color} - ${item.size}"; // or item.variantName
    final int qty = item.quantity;
    final double price = item.price;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_,__,___) => const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15)
                ),
                const SizedBox(height: 5),
                Text("Phân loại: $variant",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("x$qty", style: const TextStyle(fontSize: 13)),
                    Text(
                        Product.formatCurrency(price),
                        style: const TextStyle(fontSize: 13)
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


  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING: return "Chờ xác nhận";
      case OrderStatus.SHIPPED: return "Đang giao";
      case OrderStatus.DELIVERED: return "Hoàn thành";
      default: return "";
    }
  }
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, backgroundColor: Colors.grey[800]),
    );
  }
}