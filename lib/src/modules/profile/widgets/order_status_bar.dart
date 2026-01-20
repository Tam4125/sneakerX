import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/modules/profile/view/order_history_view.dart';

class OrderStatusBar extends StatelessWidget {
  const OrderStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("My Orders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: const [
                    Text("Order History", style: TextStyle(color: Colors.grey, fontSize: 12)),
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
              _buildStatusItem(context, Icons.receipt_long_outlined, "Pending", 0),
              _buildStatusItem(context, Icons.inventory_2_outlined, "Pending", 1),
              _buildStatusItem(context, Icons.local_shipping_outlined, "Pending", 2),
              _buildStatusItem(context, Icons.star_border, "Rate", -1),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderHistoryView(initialIndex: index))
        );
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 28, color: Colors.black87),
              // if (index == 1 || index == 2) // Example badges
              //   Positioned(
              //     right: -4, top: -4,
              //     child: Container(
              //       padding: const EdgeInsets.all(4),
              //       decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              //       child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              //     ),
              //   )
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}