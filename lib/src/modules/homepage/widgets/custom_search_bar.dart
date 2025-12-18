import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.search, color: Colors.grey[600], size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(fontSize: 15, color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.camera_alt, color: Colors.orange[700], size: 22),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
          Icon(Icons.shopping_cart_outlined, color: Colors.black87, size: 28),
          SizedBox(width: 16),
          Icon(Icons.chat_bubble_outline, color: Colors.black87, size: 28),
        ],
      ),
    );
  }
}