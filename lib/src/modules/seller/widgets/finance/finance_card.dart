import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snkrxx/data/mock_transaction_data.dart';

class FinanceCard extends StatelessWidget {
  final Transaction transaction;

  const FinanceCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _text(transaction.amount),
                _text('Mã giao dịch: ${transaction.id}'),
                _text('Loại: ${transaction.type}'),
                _text('Thời gian: ${transaction.date}'),
              ],
            ),
          ),
          Icon(
            Icons.arrow_outward,
            color: Color(0xff000000),
            size: 48, ),
        ],
      ),
    );
  }
  Widget _text(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 12,
      ),
    );
  }
}