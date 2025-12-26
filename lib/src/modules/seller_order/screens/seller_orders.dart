import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/models/enums/order_status.dart';
import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/modules/checkout/dtos/update_order_request.dart';
import 'package:sneakerx/src/modules/seller_dashboard/widgets/icon_button_widget.dart';
import 'package:sneakerx/src/modules/seller_order/widgets/order_group_card.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/order_service.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> with SingleTickerProviderStateMixin {
  final ShopService _shopService = ShopService();
  final OrderService _orderService = OrderService();
  late TabController _tabController;

  // Cache all orders
  List<Order>? _allOrders;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // 4 Tabs: All, Pending, Shipping, Completed/Cancelled
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      // Use the service that returns List<Order>
      final orders = await _shopService.getShopOrders(auth.shopId!);
      setState(() {
        _allOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int orderId, OrderStatus newStatus) async {
    setState(() => _isUpdating = true);

    UpdateOrderStatusRequest request = UpdateOrderStatusRequest(
      orderId: orderId,
      orderStatus: newStatus
    );

    final order = await _orderService.updateOrderStatus(request);
    setState(() => _isUpdating = false);

    if (order != null) {
      _loadData(); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật trạng thái thành công")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi cập nhật trạng thái")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopId = Provider.of<AuthProvider>(context, listen: false).shopId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Quản lý đơn hàng', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF86F4B5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF86F4B5),
          tabs: const [
            Tab(text: "Tất cả"),
            Tab(text: "Chờ xác nhận"),
            Tab(text: "Đang giao"),
            Tab(text: "Lịch sử"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allOrders == null || _allOrders!.isEmpty
          ? _buildEmptyState()
          : TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(_allOrders!, shopId!), // All
          _buildOrderList(_filterOrders([OrderStatus.PENDING]), shopId), // Pending
          _buildOrderList(_filterOrders([OrderStatus.SHIPPED, OrderStatus.PAID]), shopId), // Shipping
          _buildOrderList(_filterOrders([OrderStatus.DELIVERED, OrderStatus.CANCELLED]), shopId), // History
        ],
      ),
    );
  }

  List<Order> _filterOrders(List<OrderStatus> statuses) {
    if (_allOrders == null) return [];
    return _allOrders!.where((o) => statuses.contains(o.orderStatus)).toList();
  }

  Widget _buildOrderList(List<Order> orders, int shopId) {
    if (orders.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return SellerOrderGroupCard(
            order: order,
            isUpdating: _isUpdating,
            currentShopId: shopId,
            onStatusUpdate: () {
              OrderStatus nextStatus = OrderStatus.SHIPPED;
              if (order.orderStatus == OrderStatus.PENDING) nextStatus = OrderStatus.SHIPPED;
              _updateStatus(order.orderId, nextStatus);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Chưa có đơn hàng nào", style: GoogleFonts.inter(color: Colors.grey)),
        ],
      ),
    );
  }
}