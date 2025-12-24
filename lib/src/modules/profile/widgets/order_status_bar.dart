import 'package:flutter/material.dart';
import 'package:sneakerx/src/modules/profile/view/order_history_view.dart';

class OrderStatusBar extends StatelessWidget {
  const OrderStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Đơn mua", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: const [
                    Text("Xem lịch sử mua hàng", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                  ],
                )
              ],
            ),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(
                Icons.receipt_long_outlined,
                "Chờ xác nhận",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderHistoryView(initialIndex: 0,)
                    )
                  );
                }
              ),
              _buildItem(
                Icons.inventory_2_outlined,
                "Chờ lấy hàng",
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderHistoryView(initialIndex: 1,)
                      )
                  );
                }
              ),
              _buildItem(
                Icons.local_shipping_outlined,
                "Chờ giao hàng",
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderHistoryView(initialIndex: 2,)
                      )
                  );
                }
              ),
              _buildItem(Icons.star_border, "Đánh giá", null),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, VoidCallback? onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Column(
        children: [
          Icon(icon, size: 28, color: Colors.black54),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
}