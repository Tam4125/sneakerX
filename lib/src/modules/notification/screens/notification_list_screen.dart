import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'notification_detail_screen.dart'; // Import màn hình chi tiết

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  // Biến lọc: null = tất cả, còn lại theo type
  NotificationType? _selectedType;
  List<NotificationModel> _allNotifications = [];

  @override
  void initState() {
    super.initState();
    _allNotifications = NotificationMockData.getNotifications();
  }

  // Hàm lấy danh sách sau khi lọc
  List<NotificationModel> get _filteredNotifications {
    if (_selectedType == null) return _allNotifications;
    return _allNotifications.where((n) => n.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Thông báo", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          // A. PHẦN HEADER (BỘ LỌC)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton(
                  icon: Icons.local_offer,
                  label: "Khuyến mãi",
                  color: Colors.orange,
                  type: NotificationType.promotion,
                ),
                _buildFilterButton(
                  icon: Icons.newspaper,
                  label: "Tin tức",
                  color: Colors.blue,
                  type: NotificationType.news,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // B. PHẦN BODY (DANH SÁCH TIN)
          Expanded(
            child: ListView.separated(
              itemCount: _filteredNotifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
              itemBuilder: (context, index) {
                final notification = _filteredNotifications[index];
                return _buildNotificationItem(notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget nút bộ lọc
  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required Color color,
    required NotificationType type,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          // Nếu đang chọn rồi thì bỏ chọn (về null), chưa chọn thì set
          if (_selectedType == type) {
            _selectedType = null;
          } else {
            _selectedType = type;
          }
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.1), // Đậm nếu chọn, nhạt nếu không
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: color, width: 2) : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.grey[700],
            ),
          )
        ],
      ),
    );
  }

  // Widget Item thông báo
  Widget _buildNotificationItem(NotificationModel item) {
    // Logic màu nền: Chưa đọc thì màu cam nhạt/xám, Đã đọc thì trắng
    final bgColor = item.isRead ? Colors.white : Colors.orange.withOpacity(0.05);
    final titleWeight = item.isRead ? FontWeight.normal : FontWeight.bold;

    return InkWell(
      onTap: () {
        // Khi bấm vào thì đánh dấu đã đọc
        setState(() {
          item.isRead = true;
        });
        // Chuyển sang màn hình chi tiết
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(notification: item),
          ),
        );
      },
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], width: 60, height: 60),
              ),
            ),
            const SizedBox(width: 12),

            // 2. Nội dung ở giữa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: titleWeight,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.shortDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // 3. Thời gian & Trạng thái (Bên phải)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${item.time.hour}:${item.time.minute.toString().padLeft(2,'0')}", // Giả lập giờ
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  // Chấm đỏ nếu chưa đọc
                  if (!item.isRead)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}