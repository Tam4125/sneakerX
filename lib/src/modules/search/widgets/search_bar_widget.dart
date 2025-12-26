import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final VoidCallback? onSearch;
  final VoidCallback? onCameraPressed;
  final VoidCallback? onQRPressed;
  final bool readOnly;

  const SearchBarWidget({
    Key? key,
    this.hintText = 'Search...',
    this.controller,
    this.onTap,
    this.onSearch,
    this.onCameraPressed,
    this.onQRPressed,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.camera_alt_outlined, color: Colors.grey[700], size: 20),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              onSubmitted: (value) => onSearch?.call(),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.qr_code_scanner, color: Colors.grey[700], size: 20),
          ),
          GestureDetector(
            onTap: onSearch,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.search, color: Colors.black, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}