import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/modules/auth_features/views/introduction_screen.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/order_status_bar.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key,});

  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if(authProvider.isGuest) {
      return IntroductionScreen();
    } else {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Màu nền xám nhạt toàn trang
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Header (Cam)
              ProfileHeader(user: user!),
              // 2. Đơn mua (Order Status)
              OrderStatusBar(),
              const SizedBox(height: 10),
              // 3. Tiện ích (Chỉ giữ lại những cái cơ bản như yêu cầu)
              _buildUtilityMenu(),
              const SizedBox(height: 10),
              // 4. Có thể bạn cũng thích (Grid View)
              // const RecommendationGrid(),
            ],
          ),
        ),
      );
    }
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
        leading: Icon(icon, color: const Color(0xFF67D696)), // Icon màu cam
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