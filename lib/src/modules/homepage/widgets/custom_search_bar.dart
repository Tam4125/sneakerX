import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final bool readOnly;
  final VoidCallback? onTap;

  // Update constructor to accept new params
  const CustomSearchBar({
    super.key,
    this.readOnly = false, // Default is editable
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap, // Handle tap on the container
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
                        // If readOnly is true, keyboard won't show
                        readOnly: readOnly,
                        // If readOnly is true, tapping text field triggers parent onTap
                        onTap: readOnly ? onTap : null,
                        enabled: !readOnly, // Optional: creates a visual "disabled" look if needed
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