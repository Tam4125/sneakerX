import 'package:flutter/material.dart';
// --- SỬA IMPORT TẠI ĐÂY (Cùng thư mục) ---
import 'mock_order_data.dart';
// Import widget RecommendationGrid nếu bạn để ở thư mục widgets (../widgets/recommendation_grid.dart)
// Nếu chưa có, mình sẽ viết code giả lập Grid ở dưới luôn cho tiện.

class OrderHistoryView extends StatefulWidget {
  final int initialIndex;

  const OrderHistoryView({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF8B5FBF); // Màu tím chủ đạo
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialIndex);
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
            Tab(text: "Chờ lấy hàng"),
            Tab(text: "Chờ giao hàng"),
            Tab(text: "Đã giao"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(OrderStatus.waitConfirm),
          _buildTabContent(OrderStatus.waitPickup),
          _buildTabContent(OrderStatus.shipping),
          _buildTabContent(OrderStatus.delivered),
        ],
      ),
    );
  }

  // Nội dung từng Tab
  Widget _buildTabContent(OrderStatus status) {
    final orders = MockOrderData.getOrdersByStatus(status);

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
                          image: AssetImage("assets/images/empty_order.png"), // Bạn cần thêm ảnh này hoặc dùng Icon
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

            // 2. Tiêu đề "Có thể bạn cũng thích"
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 1, width: 50, color: Colors.grey[300]),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Có thể bạn cũng thích", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ),
                  Container(height: 1, width: 50, color: Colors.grey[300]),
                ],
              ),
            ),

            // 3. Grid Sản phẩm gợi ý (Giả lập giống ảnh)
            _buildRecommendationGrid(),
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

  // --- WIDGET CARD ĐƠN HÀNG ---
  Widget _buildOrderItem(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(_getStatusText(order.status), style: TextStyle(color: primaryColor, fontSize: 13)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(order.productImage, width: 70, height: 70, fit: BoxFit.cover),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 5),
                      Text("Phân loại: ${order.variant}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("x${order.quantity}", style: const TextStyle(fontSize: 13)),
                          Text(order.formattedPrice, style: const TextStyle(fontSize: 13)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Thành tiền: ", style: TextStyle(fontSize: 14)),
                Text(order.formattedTotal, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          // Nút hành động
          if (order.status == OrderStatus.waitPickup || order.status == OrderStatus.waitConfirm)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: (){},
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

  // --- WIDGET GRID GỢI Ý (Giả lập để hiển thị đẹp như ảnh) ---
  Widget _buildRecommendationGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 4, // Hiển thị 4 sản phẩm mẫu
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.asset("assets/images/ngoc.jpg", width: double.infinity, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Giày Sneaker Thể Thao Nam Nữ", maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("129.000đ", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          const Text("Đã bán 888", style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitConfirm: return "Chờ xác nhận";
      case OrderStatus.waitPickup: return "Chờ lấy hàng";
      case OrderStatus.shipping: return "Đang giao";
      case OrderStatus.delivered: return "Hoàn thành";
      default: return "";
    }
  }
}