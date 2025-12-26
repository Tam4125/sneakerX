import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/models/enums/order_status.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';
import 'package:intl/intl.dart';

// --- NEW WIDGET: THE GROUPED ORDER CARD ---
class SellerOrderGroupCard extends StatelessWidget {
  final int currentShopId;
  final Order order;
  final VoidCallback? onStatusUpdate;
  final bool isUpdating;

  const SellerOrderGroupCard({
    Key? key,
    required this.order,
    required this.currentShopId,
    this.onStatusUpdate,
    this.isUpdating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myShopItems = order.orderItems.where((item) {
      return item.product.shopId == currentShopId;
    }).toList();

    final double shopTotal = myShopItems.fold(0, (sum, item) {
      return sum + (item.price * item.quantity);
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // --- HEADER: Order ID & Status ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "Đơn #${order.orderId}",
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                _buildStatusChip(order.orderStatus),
              ],
            ),
          ),

          // --- BODY: List of Items ---
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: myShopItems.length,
            itemBuilder: (context, index) {
              final item = myShopItems[index];
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.images.isNotEmpty
                            ? item.product.images.first.imageUrl
                            : "https://via.placeholder.com/100",
                        width: 70, height: 70, fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Product Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          // Text(
                          //   "Phân loại: ${item.}", // e.g. Size 42
                          //   style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                          // ),
                          // const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("x${item.quantity}", style: GoogleFonts.inter(fontSize: 13)),
                              Text(
                                Product.formatCurrency(item.price),
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // --- FOOTER: Total & Actions ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Tổng đơn hàng: ", style: GoogleFonts.inter(fontSize: 12)),
                    Text(
                      Product.formatCurrency(shopTotal),
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action Buttons based on Status
                if (order.orderStatus == OrderStatus.PENDING)
                  _buildActionButton("Xác nhận đơn", Colors.blue, "SHIPPED"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, String nextStatus) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isUpdating ? null : () {
          // Trigger the callback with the next status
          if (onStatusUpdate != null) onStatusUpdate!();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: isUpdating
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;
    switch (status) {
      case OrderStatus.PENDING: color = Colors.orange; text = "Chờ xác nhận"; break;
      case OrderStatus.SHIPPED: color = Colors.blue; text = "Đang giao"; break;
      case OrderStatus.PAID: color = Colors.blue; text = "Đang giao"; break;
      case OrderStatus.DELIVERED: color = Colors.green; text = "Hoàn thành"; break;
      case OrderStatus.CANCELLED: color = Colors.red; text = "Đã hủy"; break;
      default: color = Colors.grey; text = status.name;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}