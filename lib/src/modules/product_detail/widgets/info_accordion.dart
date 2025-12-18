import 'package:flutter/material.dart';

class InfoAccordion extends StatefulWidget {
  final String title;
  final String? content;

  const InfoAccordion({Key? key, required this.title, this.content}) : super(key: key);

  @override
  State<InfoAccordion> createState() => _InfoAccordionState();
}

class _InfoAccordionState extends State<InfoAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Canh lề và tạo khoảng cách giữa các mục
      margin: const EdgeInsets.only(top: 8, left: 5, right: 5),

      decoration: BoxDecoration(
        // --- SỬA THÀNH GRADIENT TẠI ĐÂY ---
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF6A408D), // Màu tím đậm hơn ở bên trái
            Color(0xFF8B5FBF), // Màu tím sáng hơn ở bên phải
          ],
        ),
        borderRadius: BorderRadius.circular(8), // Bo góc nhẹ giống ảnh
      ),

      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // Icon mũi tên
          trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
            color: Colors.white,
          ),
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,

          // Tiêu đề
          title: Text(
            widget.title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15
            ),
          ),

          // Nội dung
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.content ?? "Chưa có thông tin chi tiết.",
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
            )
          ],
        ),
      ),
    );
  }
}