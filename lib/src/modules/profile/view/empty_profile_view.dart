import 'package:flutter/material.dart';
// Import các widget con đã có (Đảm bảo đường dẫn đúng)
import '../widgets/order_status_bar.dart';

class EmptyProfileView extends StatelessWidget {
  const EmptyProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Nền xám nhạt
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER DÀNH RIÊNG CHO KHÁCH
            _buildGuestHeader(context),

            // 2. THANH TRẠNG THÁI ĐƠN HÀNG (Dùng lại widget cũ)
            const OrderStatusBar(),

            const SizedBox(height: 10),

            // 3. MENU TIỆN ÍCH
            _buildUtilityMenu(context),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HEADER RIÊNG CHO KHÁCH ---
  Widget _buildGuestHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 30,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF86F4B5), Color(0xFFC8FFDB)], // Gradient xanh của bạn
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          // Hàng Icon trên cùng
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: Colors.black87)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87)),
            ],
          ),

          const SizedBox(height: 10),

          // Phần Avatar và Nút bấm
          Row(
            children: [
              // Avatar mặc định
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5), // Nền trắng mờ
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 20),

              // Nút Đăng nhập / Đăng ký
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chào mừng đến với NeakerX",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Nút Đăng nhập (Nền trắng)
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Điều hướng sang màn hình Login
                            // Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            minimumSize: const Size(0, 36), // Chiều cao nút
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text("Đăng nhập", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),

                        const SizedBox(width: 10),

                        // Nút Đăng ký (Viền trắng)
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Điều hướng sang màn hình Register
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: const Text("Đăng ký", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // --- MENU TIỆN ÍCH ---
  Widget _buildUtilityMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(Icons.confirmation_number_outlined, "Kho Voucher", "Đăng nhập để xem"),
        const Divider(height: 1, indent: 50),
        _buildMenuItem(Icons.card_membership, "Khách hàng thân thiết", "Ưu đãi thành viên"),
        const Divider(height: 1, indent: 50),
        _buildMenuItem(Icons.favorite_border, "Đã thích", "0 Sản phẩm"),
        const Divider(height: 1, indent: 50),
        _buildMenuItem(Icons.help_outline, "Trung tâm trợ giúp", ""),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF67D696)), // Màu xanh icon
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtitle.isNotEmpty)
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
        onTap: () {
        },
      ),
    );
  }
}