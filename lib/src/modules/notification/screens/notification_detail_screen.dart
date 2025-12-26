import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Xác định tiêu đề AppBar và Nút dựa trên loại tin
    final isPromo = notification.type == NotificationType.promotion;
    final appBarTitle = isPromo ? "Chi tiết Khuyến mãi" : "Tin tức Sneaker";
    final btnText = isPromo ? "Lấy Voucher Ngay" : "Xem Sản Phẩm";
    final btnColor = isPromo ? Colors.orange : Colors.blue;

    return Scaffold(
      backgroundColor: Colors.white,
      // A. APP BAR
      appBar: AppBar(
        title: Text(appBarTitle, style: const TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),

      // B. BODY (NỘI DUNG)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh bìa Full Width 16:9
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                notification.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_,__,___) => Container(color: Colors.grey[300]),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Tiêu đề lớn
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. Thời gian
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "${notification.time.day}/${notification.time.month} - ${notification.time.hour}:${notification.time.minute}",
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 4. Nội dung chi tiết
                  Text(
                    notification.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6, // Giãn dòng dễ đọc
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // C. FOOTER (KHU VỰC HÀNH ĐỘNG)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
            ]
        ),
        child: SizedBox(
          height: 50, // Chiều cao nút
          child: ElevatedButton(
            onPressed: () {
              // Xử lý hành động sau này
              print("Đã bấm nút: $btnText");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              btnText.toUpperCase(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}