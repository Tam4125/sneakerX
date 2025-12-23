import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/modules/seller/widgets/seller/icon_button_widget.dart';
import 'dart:io';
import 'package:sneakerx/src/modules/seller_signup/widgets/textfield.dart';
import 'package:sneakerx/src/modules/seller_order/mockdata/order_mock_data.dart';
import 'package:sneakerx/src/modules/seller_order/widgets/order_card.dart';

class SellerOrders extends StatefulWidget {
  const SellerOrders({Key? key}) : super(key: key);

  @override
  State<SellerOrders> createState() => _SellerOrders();
}

class _SellerOrders extends State<SellerOrders> {
  final order = OrderMockData.GetShopData();

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,

        leading: IconButtonWidget(
            icon: Icons.arrow_back,
            onPressed: () {
              _showMessage('its printed!');
            }
        ),
        title:
        Text(
          'Theo dõi đơn hàng',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
      ),
      body:
      Padding(
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
        child:
        Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
          child: ListView.builder(
                itemCount: order.length,
                itemBuilder: (context, index) {
                  return OrderCard(
                    order: order[index],
                  );
                },
              )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
