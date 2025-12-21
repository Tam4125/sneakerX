import 'package:flutter/material.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_response.dart';
import 'package:sneakerx/src/screens/seller_main_screen.dart';

class ProfileHeader extends StatelessWidget {
  final UserSignInResponse user;
  const ProfileHeader({
    super.key,
    required this.user
});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 30,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF86F4B5), Color(0xFFC8FFDB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          // ... (Phần Row trên cùng giữ nguyên)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SellerMainScreen()
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.storefront_outlined, size: 18),
                label: const Row(children: [Text("Bắt đầu bán", style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(width: 4), Icon(Icons.chevron_right, size: 18)]),
              ),
              Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: Colors.black87)),
                  Stack(children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87)),
                    Positioned(right: 5, top: 5, child: Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)), constraints: const BoxConstraints(minWidth: 16, minHeight: 16), child: const Text('53', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
                  ]),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. THÔNG TIN NGƯỜI DÙNG
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      image: const DecorationImage(
                        // --- SỬA TẠI ĐÂY: Dùng AssetImage cho file nội bộ ---
                          image: NetworkImage("assets/images/ngoc.jpg"),
                          fit: BoxFit.cover
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              // ... (Phần thông tin tên và follow giữ nguyên)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Text(user.username, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(1), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Text("Bạc", style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)), Icon(Icons.chevron_right, size: 16, color: Colors.black54)]))]),
                    const SizedBox(height: 8),
                    const Row(children: [Text("0 Người theo dõi", style: TextStyle(color: Colors.black, fontSize: 14)), SizedBox(width: 15), Text("12 Đang theo dõi", style: TextStyle(color: Colors.black, fontSize: 14))])
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}