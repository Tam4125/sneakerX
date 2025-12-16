import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardCard extends StatelessWidget {
  final VoidCallback onTap;
  final String followers;
  final String revenue;
  final String returnRate;
  final String reviewCount;

  const DashboardCard({
    Key? key,
    required this.onTap,
    required this.followers,
    required this.revenue,
    required this.returnRate,
    required this.reviewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        Icons.arrow_outward,
                        color: Color(0xff86f4b5),
                        size: 48,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatItem('Chờ lấy hàng:', followers),
                        const SizedBox(height: 16),
                        _buildStatItem('Đơn hủy:', revenue),
                        const SizedBox(height: 16),
                        _buildStatItem('Trả hàng/Hoàn tiền:', returnRate),
                        const SizedBox(height: 16),
                        _buildStatItem('Phản hồi đánh giá:', reviewCount),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.robotoMono(
            color: Colors.grey[400],
            fontSize: 14,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}