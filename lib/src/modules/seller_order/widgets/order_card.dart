import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/models/order_item.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/services/order_service.dart';

class OrderCard extends StatefulWidget {
  final OrderItem order;

  const OrderCard({
    super.key,
    required this.order,
  });

  @override
  State<OrderCard> createState() => _OrderCartState();
}

class _OrderCartState extends State<OrderCard> {
  final OrderService _orderService = OrderService();

  late Future<Order?> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = _orderService.getOrderDetail(widget.order.orderId);
  }


  @override
  Widget build(BuildContext context) {

    final Product product = widget.order.product;
    final productImage = product.images.isNotEmpty ? product.images.first.imageUrl : "https://res.cloudinary.com/dprivf9nt/image/upload/v1765862315/cld-sample-5.jpg";
    final orderItem = widget.order;

    return FutureBuilder<Order?>(
      future: _orderFuture,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text("Order item ${orderItem.orderId} not found"));
        }

        final parentOrder = snapshot.data!;

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
                        image: NetworkImage(productImage),
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
                            'Mã đơn hàng: ${orderItem.orderId}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w200,
                              letterSpacing: -0.6,
                              color: Colors.grey[300],
                            ),
                          ),
                          Text(
                            product.name,
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
                            '${orderItem.price}₫',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF86F4B5),
                            ),
                          ),

                          Text(
                            'Phương thức thanh toán: ${parentOrder.payment.provider}',
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
                      parentOrder.orderStatus.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Text(
                  //   '${order.createdAt}',
                  //   style: GoogleFonts.inter(
                  //     fontSize: 10,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
