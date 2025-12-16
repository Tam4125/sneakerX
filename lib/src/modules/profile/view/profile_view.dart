import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/order_status_bar.dart';
import '../widgets/recommendation_grid.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Màu nền xám nhạt toàn trang
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header (Cam)
            const ProfileHeader(),

            // 2. Đơn mua (Order Status)
            const OrderStatusBar(),
            const SizedBox(height: 10),

            // 3. Tiện ích (Chỉ giữ lại những cái cơ bản như yêu cầu)
            _buildUtilityMenu(),
            const SizedBox(height: 10),

            // 4. Có thể bạn cũng thích (Grid View)
            const RecommendationGrid(),
          ],
        ),
      ),
    );
  }

  // Widget menu tiện ích rút gọn
  Widget _buildUtilityMenu() {
    return Column(
      children: [
        _buildMenuItem(Icons.confirmation_number_outlined, "Kho Voucher", "50+ Voucher"),
        const Divider(height: 1, indent: 50),
        _buildMenuItem(Icons.card_membership, "Khách hàng thân thiết", "Thành viên Bạc"),
        const Divider(height: 1, indent: 50),
        _buildMenuItem(Icons.favorite_border, "Đã thích", "12 Sản phẩm"),
        const Divider(height: 1, indent: 50),
        _buildMenuItem(Icons.help_outline, "Trung tâm trợ giúp", ""),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xf4ffff)), // Icon màu cam
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtitle.isNotEmpty)
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}