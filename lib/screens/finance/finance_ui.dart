import 'package:flutter/material.dart';
import 'package:snkrxx/data/mock_transaction_data.dart';
import 'package:snkrxx/widgets/finance_card.dart';
import 'package:snkrxx/widgets/icon_button_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';


class FinanceUi extends StatefulWidget {
  const FinanceUi({Key? key}) : super(key: key);

  @override
  State<FinanceUi> createState() => _FinanceUi();
}

class _FinanceUi extends State<FinanceUi> {
  String _activeTab = 'products';

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
          onPressed: () => context.go('/'),
        ),
        title:
        Text(
          'Tài Chính',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButtonWidget(
            icon: Icons.help_outline,
            onPressed: () => _showMessage('Help clicked'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.3, // 30% of screen
              color: Color(0xff67d696),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Số dư hiện tại',
                    style: GoogleFonts.robotoMono(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                    ),
                  ),
                  Text('67.000.000đ',
                    style: GoogleFonts.inter(
                        fontSize: 32,
                        color: Color(0xff000000)
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 60,
            width: double.infinity,
            color: Colors.grey[900],
            child:
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lịch sử',
                  style: GoogleFonts.robotoMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
                itemCount: MockTransactionData.transaction.length,
                itemBuilder: (context, index) {
                  return FinanceCard(
                    transaction: MockTransactionData.transaction[index],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}