import 'package:flutter/material.dart';
import '../../../data/models/product_image.dart';
import '../../../config/app_colors.dart';

// Chuyển thành StatefulWidget
class ProductHeader extends StatefulWidget {
  final List<ProductImage> images;

  const ProductHeader({Key? key, required this.images}) : super(key: key);

  @override
  State<ProductHeader> createState() => _ProductHeaderState();
}

class _ProductHeaderState extends State<ProductHeader> {
  // Biến theo dõi trang hiện tại
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // 1. Phần PageView lướt ảnh
            Container(
              height: 350, // Tăng chiều cao một chút cho đẹp
              width: double.infinity,
              color: Colors.grey[200],
              child: PageView.builder(
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index; // Cập nhật trang hiện tại khi lướt
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.images[index].imageUrl,
                    fit: BoxFit.cover,
                    // Thêm loading builder để tránh lỗi khi mạng chậm
                    loadingBuilder: (ctx, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (ctx, err, stackTrace) => const Icon(Icons.error),
                  );
                },
              ),
            ),

            // Nút Back
            Positioned(
              top: 40, left: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ),

            // Nút Giỏ hàng
            Positioned(
              top: 40, right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ),

            // 2. Phần dấu chấm chỉ báo (Indicators) ở góc dưới ảnh
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.images.asMap().entries.map((entry) {
                  int idx = entry.key;
                  // Kiểm tra xem có phải trang hiện tại không
                  bool isActive = idx == _currentPage;
                  return Container(
                    width: isActive ? 12.0 : 8.0, // Trang hiện tại thì chấm to hơn
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Trang hiện tại màu trắng, trang khác màu xám
                      color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        // Thanh Flash Sale (Giữ nguyên)
        Container(
          height: 40,
          color: AppColors.flashSale,
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