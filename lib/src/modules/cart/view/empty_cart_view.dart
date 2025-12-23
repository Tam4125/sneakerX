import 'package:flutter/material.dart';

class EmptyCartView extends StatelessWidget {
  const EmptyCartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF8B5FBF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Nền xám nhạt
      appBar: AppBar(
        title: const Text("Giỏ hàng", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),

            // 1. ICON GIỎ HÀNG
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
            ),
            const SizedBox(height: 20),

            // 2. TEXT THÔNG BÁO
            const Text(
              '"Hổng" có gì trong giỏ hết',
              style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lướt NeakerX, lựa hàng ngay đi!',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // 3. NÚT MUA SẮM NGAY (Màu Tím)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              child: const Text("Mua sắm ngay!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),

            // 4. NÚT ĐĂNG NHẬP (Viền Tím)
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text("Đăng nhập / Đăng ký", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 50),

            // 5. BANNER QUÀ CHÀO MỪNG
            _buildWelcomeBanner(),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EA), // Nền cam nhạt giống ảnh
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        children: [
          // Tiêu đề & Đồng hồ đếm ngược
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text("Quà chào mừng dành cho bạn", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
              const SizedBox(width: 8),
              const Icon(Icons.celebration, color: Colors.orange, size: 20),
            ],
          ),
          const SizedBox(height: 8),

          // Đồng hồ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeBox("03"), const Text(" : ", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTimeBox("44"), const Text(" : ", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTimeBox("19"),
            ],
          ),
          const SizedBox(height: 16),

          // VOUCHER TICKET
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                // Phần bên trái (Free Ship) - Dùng Gradient Xanh của bạn
                Container(
                  width: 90,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),

                    // --- SỬA Ở ĐÂY ---
                    color: Color(0xFF00BFA5), // Dùng 'color' thay vì 'gradient'
                    // -----------------

                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("FREE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("SHIP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),

                // Phần đường kẻ đứt
                SizedBox(
                  width: 1,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate((constraints.constrainHeight() / 6).floor(), (index) =>
                      const SizedBox(width: 1, height: 3, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey))),
                      ),
                    );
                  }),
                ),

                // Phần nội dung bên phải
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Giảm tối đa 500kđ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(height: 0),
                            Text("Đơn tối thiểu 0đ", style: TextStyle(color: Colors.black, fontSize: 12)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5), // Màu xanh nút đăng ký
                            minimumSize: const Size(60, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            elevation: 0,
                          ),
                          child: const Text("Đăng ký", style: TextStyle(color: Colors.white, fontSize: 12)),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimeBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}