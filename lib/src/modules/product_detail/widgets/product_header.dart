import 'package:flutter/material.dart';
import '../../../data/models/product_image.dart';
import '../../../config/app_colors.dart';
import 'product_video_player.dart'; // <--- NHỚ IMPORT FILE VỪA TẠO

class ProductHeader extends StatefulWidget {
  final List<ProductImage> images;

  const ProductHeader({Key? key, required this.images}) : super(key: key);

  @override
  State<ProductHeader> createState() => _ProductHeaderState();
}

class _ProductHeaderState extends State<ProductHeader> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // 1. PAGEVIEW LƯỚT ẢNH & VIDEO
            Container(
              height: 350,
              width: double.infinity,
              color: Colors.grey[200],
              child: PageView.builder(
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final String url = widget.images[index].imageUrl;

                  // --- LOGIC KIỂM TRA VIDEO ---
                  // Cách 1: Kiểm tra đuôi file (mp4, mov, avi...)
                  if (url.endsWith('.mp4')) {
                    return ProductVideoPlayer(
                      videoUrl: url,
                      // Nếu url bắt đầu bằng 'assets/' thì là file nội bộ, ngược lại là link mạng
                      isLocalAsset: url.startsWith('assets/'),
                    );
                  }

                  // --- LOGIC HIỂN THỊ ẢNH ---
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (ctx, err, stackTrace) => const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                  );
                },
              ),
            ),

            // 2. INDICATORS (DẤU CHẤM TRANG)
            Positioned(
              bottom: 10, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.images.asMap().entries.map((entry) {
                  int idx = entry.key;
                  bool isActive = idx == _currentPage;
                  return Container(
                    width: isActive ? 12.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                        border: Border.all(color: Colors.black12)
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        // 3. FLASHSALE BAR
        Container(
          height: 40,
          color: const Color(0xFF86f4b5), // Màu cam Flashsale
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("FLASHSALE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Row(children: [
                const Text("KẾT THÚC TRONG ", style: TextStyle(color: Colors.white, fontSize: 10)),
                _buildTimeBox("01"), const Text(":"),
                _buildTimeBox("14"), const Text(":"),
                _buildTimeBox("25")
              ]),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTimeBox(String t) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(2),
      color: Colors.black,
      child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 10))
  );
}