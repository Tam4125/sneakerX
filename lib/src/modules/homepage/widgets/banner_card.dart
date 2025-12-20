import 'package:flutter/material.dart';
import '../models/banner.dart';

class BannerCard extends StatelessWidget {
  final BannerModel banner;

  const BannerCard({
    Key? key,
    required this.banner,
  }) : super(key: key);

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _hexToColor(banner.backgroundColor),
        borderRadius: BorderRadius.circular(12),
      ),
      // LƯU Ý 1: Giảm padding từ 16 xuống 8 hoặc 10 để tránh mất diện tích
      padding: EdgeInsets.all(8),

      // LƯU Ý 2: Bọc nội dung trong SingleChildScrollView
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Cho phép lướt ngang
        child: ConstrainedBox(
          // Đảm bảo nội dung vẫn cố gắng chiếm chiều cao của thẻ cha nếu cần
          constraints: BoxConstraints(
            minHeight: 80, // Chiều cao tối thiểu (tùy chỉnh theo design của bạn)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    // Nếu muốn text không xuống dòng mà chạy ngang thì bỏ comment dòng dưới
                    // maxLines: 1,
                  ),
                  Text(
                    banner.subtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4), // Tạo khoảng cách nhỏ
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.yellow[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      banner.buttonText,
                      style: TextStyle(
                        fontSize: 8, // Tăng nhẹ font size nút bấm cho dễ đọc
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 8, color: Colors.black87),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}