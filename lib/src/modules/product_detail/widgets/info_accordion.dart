// File: src/modules/product_detail/widgets/info_accordion.dart
import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

class InfoAccordion extends StatelessWidget {
  final String title;
  final String? content;

  const InfoAccordion({Key? key, required this.title, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      color: AppColors.secondary, // Nền tím
      child: Theme(
        // Xóa đường kẻ mặc định của ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content ?? "Chưa có thông tin chi tiết cho mục này.",
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            )
          ],
        ),
      ),
    );
  }
}