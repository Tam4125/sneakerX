import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class ProductFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final int? selectedCategoryId;
  final String selectedStatus;
  final List<MediaItem> mediaItems;
  final Function(int?) onCategoryChanged;
  final Function(String) onStatusChanged;
  final Function(String type) onPickMedia;
  final Function(int oldIndex, int newIndex) onMediaReorder;
  final Function(int index) onMediaRemove;

  const ProductFormWidget({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    required this.stockController,
    required this.selectedCategoryId,
    required this.selectedStatus,
    required this.mediaItems,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onPickMedia,
    required this.onMediaReorder,
    required this.onMediaRemove,
  }) : super(key: key);

  @override
  State<ProductFormWidget> createState() => _ProductFormWidgetState();
}

class _ProductFormWidgetState extends State<ProductFormWidget> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Media Section
          _buildMediaSection(),
          const SizedBox(height: 24),

          // Product Name
          TextFormField(
            controller: widget.nameController,
            decoration: InputDecoration(
              labelText: 'Tên sản phẩm',
              labelStyle: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 15,
                letterSpacing: -0.6,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'nhập dô đi bro';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: widget.descriptionController,
            decoration: InputDecoration(
              labelText: 'Mô tả sản phẩm',
              labelStyle: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 15,
                letterSpacing: -0.6,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          // Category Dropdown
          DropdownButtonFormField<int>(
            value: widget.selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'Danh mục sản phẩm *',
              labelStyle: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 15,
                letterSpacing: -0.6,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 1,
                child: Text(
                  'Giày Nam',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 15,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text(
                  'Giày Nữ',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 15,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 3,
                child: Text(
                  'Giày con nít',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 15,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
            ],
            onChanged: widget.onCategoryChanged,
            validator: (value) {
              if (value == null) return 'Chọn danh mục sản phẩm';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Price and Stock Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.priceController,
                  decoration: InputDecoration(
                    labelText: 'Giá bán',
                    suffixText: 'đ',
                    labelStyle: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 15,
                      letterSpacing: -0.6,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bắt buộc';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Không hợp lệ :*(';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: widget.stockController,
                  decoration: InputDecoration(
                    labelText: 'Số lượng *',
                    labelStyle: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 15,
                      letterSpacing: -0.6,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bắt buộc';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Không hợp lệ :*(';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status
          DropdownButtonFormField<String>(
            value: widget.selectedStatus,
            decoration: InputDecoration(
              labelText: 'Trạng thái',
              labelStyle: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 15,
                letterSpacing: -0.6,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 'active',
                child: Text(
                  'Đang bán',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 15,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 'hidden',
                child: Text(
                  'Ẩn',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 15,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.onStatusChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),

        Text(
          'Thêm hình ảnh/video',
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontSize: 18,
            letterSpacing: -0.6,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 16),

        // Media Grid
        if (widget.mediaItems.isNotEmpty)
          SizedBox(
            height: 120,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.mediaItems.length,
              onReorder: widget.onMediaReorder,
              itemBuilder: (context, index) {
                final item = widget.mediaItems[index];
                return Container(
                  key: ValueKey(item.path),
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.type == 'image'
                              ? Image.file(item.file, fit: BoxFit.cover)
                              : Center(
                            child: Icon(
                              Icons.videocam,
                              size: 40,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[400],
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.black,
                            ),
                            onPressed: () => widget.onMediaRemove(index),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),

        // Add Media Buttons
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => widget.onPickMedia('image'),
              icon: const Icon(Icons.image, color: Colors.black),
              label: Text(
                'Thêm ảnh',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 15,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => widget.onPickMedia('video'),
              icon: const Icon(Icons.videocam, color: Colors.black),
              label: Text(
                'Thêm video',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 15,
                  letterSpacing: -0.6,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Text(
          'Thông tin sản phẩm',
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontSize: 18,
            letterSpacing: -0.6,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class MediaItem {
  final File file;
  final String type;
  final String path;

  MediaItem({
    required this.file,
    required this.type,
    required this.path,
  });
}