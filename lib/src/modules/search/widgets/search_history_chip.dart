import 'package:flutter/material.dart';

class SearchHistoryChip extends StatelessWidget {
  final String keyword;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SearchHistoryChip({
    Key? key,
    required this.keyword,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              keyword,
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            SizedBox(width: 6),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}