import 'package:flutter/material.dart';

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
              _buildItem(Icons.receipt_long_outlined, "Chờ xác nhận"),
              _buildItem(Icons.inventory_2_outlined, "Chờ lấy hàng"),
              _buildItem(Icons.local_shipping_outlined, "Chờ giao hàng"),
              _buildItem(Icons.star_border, "Đánh giá"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.black54),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}