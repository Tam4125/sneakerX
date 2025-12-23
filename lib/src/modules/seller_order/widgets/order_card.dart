import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/modules/seller_order/models/seller_order.dart';

class OrderCard extends StatelessWidget {
  final SellerOrder order;

  const OrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Image
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    image: AssetImage(order.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã đơn hàng: ${order.orderId}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          letterSpacing: -0.6,
                          color: Colors.grey[300],
                        ),
                      ),
                      Text(
                        order.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                          color: Colors.white,
                        ),
                      ),

                      Text(
                        '${order.totalPrice}₫',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF86F4B5),
                        ),
                      ),

                      Text(
                        'Phương thức thanh toán: ${order.provider}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          letterSpacing: -0.6,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 10),

        Divider(
          color: Colors.grey[800],
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                color: Color(0xFF86F4B5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                order.orderStatus,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ),
            Text(
              '${order.createdAt}',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ],
        ),
          ],
        ),
    );
  }
}
