import 'package:flutter/material.dart';

enum NotificationType { promotion, news }

class NotificationModel {
  final int id;
  final String title;
  final String shortDescription; // Tóm tắt
  final String content;          // Nội dung chi tiết
  final String imageUrl;
  final DateTime time;
  final NotificationType type;
  bool isRead; // Trạng thái đã đọc/chưa đọc

  NotificationModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.content,
    required this.imageUrl,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class NotificationMockData {
  static List<NotificationModel> getNotifications() {
    return [
      NotificationModel(
        id: 1,
        title: "Siêu Sale 12.12 - Giảm tới 50% toàn bộ giày Nike",
        shortDescription: "Cơ hội săn giày hiệu giá hời nhất năm. Chỉ duy nhất hôm nay!",
        content: "Chào mừng đại tiệc mua sắm 12.12! SneakerX tung ra hàng ngàn voucher giảm giá cực sốc. \n\n- Giảm 50% cho dòng Air Jordan.\n- Mua 1 tặng 1 vớ cao cấp.\n- Freeship toàn quốc cho đơn từ 500k.\n\nNhanh tay kẻo hết size bạn nhé!",
        imageUrl: "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        time: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.promotion,
        isRead: false, // Chưa đọc
      ),
      NotificationModel(
        id: 2,
        title: "Ra mắt bộ sưu tập Adidas Mùa Đông 2024",
        shortDescription: "Những mẫu thiết kế ấm áp và phong cách nhất đã cập bến.",
        content: "Adidas vừa chính thức công bố bộ sưu tập Winter 2024 với chất liệu giữ nhiệt tiên tiến. \nThiết kế lần này tập trung vào sự tối giản nhưng vẫn giữ được nét cá tính mạnh mẽ.\n\nHãy đến cửa hàng gần nhất để trải nghiệm.",
        imageUrl: "https://images.unsplash.com/photo-1552346154-21d32810aba3?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        time: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.news,
        isRead: true, // Đã đọc
      ),
      NotificationModel(
        id: 3,
        title: "Voucher độc quyền dành riêng cho bạn",
        shortDescription: "Nhập mã SNEAKERX20 giảm ngay 20k.",
        content: "Cảm ơn bạn đã đồng hành cùng SneakerX. Chúng tôi gửi tặng bạn mã giảm giá đặc biệt áp dụng cho đơn hàng tiếp theo.",
        imageUrl: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1000&q=80",
        time: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.promotion,
        isRead: false, // Chưa đọc
      ),
      NotificationModel(
        id: 4,
        title: "Thông báo bảo trì hệ thống",
        shortDescription: "Hệ thống sẽ bảo trì vào lúc 00:00 đêm nay.",
        content: "Để nâng cấp trải nghiệm người dùng, SneakerX sẽ tiến hành bảo trì server trong vòng 2 tiếng. Xin lỗi vì sự bất tiện này.",
        imageUrl: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        time: DateTime.now().subtract(const Duration(days: 3)),
        type: NotificationType.news,
        isRead: true,
      ),
    ];
  }
}