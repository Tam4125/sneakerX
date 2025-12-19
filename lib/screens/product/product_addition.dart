// add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:snkrxx/data/database_helper.dart';
import 'package:snkrxx/models/product.dart';
import 'package:snkrxx/models/product_media.dart';
import 'package:snkrxx/widgets/icon_button_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class AddProductScreen extends StatefulWidget {
  final int shopId;

  const AddProductScreen({Key? key, required this.shopId}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreen();
}

class _AddProductScreen extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedStatus = 'active';
  List<MediaItem> _mediaItems = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(String type) async {
    try {
      if (type == 'image') {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (image != null) {
          setState(() {
            _mediaItems.add(MediaItem(
              file: File(image.path),
              type: 'image',
              path: image.path,
            ));
          });
        }
      } else if (type == 'video') {
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(seconds: 60),
        );
        if (video != null) {
          setState(() {
            _mediaItems.add(MediaItem(
              file: File(video.path),
              type: 'video',
              path: video.path,
            ));
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking media: $e')),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now().toIso8601String();

      // Create product
      final product = Product(
        shopId: widget.shopId,
        categoryId: _selectedCategoryId!,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        status: _selectedStatus,
        createdAt: now,
        updatedAt: now,
      );

      // Insert product into database
      final productId = await DatabaseHelper().insertProduct(product);
      // Save media files and insert into database
      for (int i = 0; i < _mediaItems.length; i++) {
        final media = _mediaItems[i];

        final productMedia = ProductMedia(
          productId: productId,
          mediaUrl: media.path,
          mediaType: media.type,
          sortOrder: i,
        );

        await DatabaseHelper().insertProductMedia(productMedia);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        context.go('/productlist/${widget.shopId}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButtonWidget(
          icon: Icons.arrow_back,
          onPressed: () => context.go('/productlist/${widget.shopId}'),
        ),
        title: Text(
          'Thêm sản phẩm',
            style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -1, )
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProduct,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Media Section
            _buildMediaSection(),
            const SizedBox(height: 24),

            // Product Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên sản phẩm',
                labelStyle: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 15,
                  letterSpacing: -0.6,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey,),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'nhập dô đi bro';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả sản phẩm',
                labelStyle: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 15,
                  letterSpacing: -0.6,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey,),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Category Dropdown (simplified - you'd fetch from DB)
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Danh mục sản phẩm *',
                labelStyle: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 15,
                  letterSpacing: -0.6,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey,),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              items: [
                DropdownMenuItem(value: 1, child: Text('Giày Nam',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 15,
                    letterSpacing: -0.6,
                  ),)),
                DropdownMenuItem(value: 2, child: Text('Giày Nữ',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 15,
                      letterSpacing: -0.6,
                    ),)),
                DropdownMenuItem(value: 3, child: Text('Giày con nít',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 15,
                    letterSpacing: -0.6,
                  ),)),
              ],
              onChanged: (value) {
                setState(() => _selectedCategoryId = value);
              },
              validator: (value) {
                if (value == null) return 'Danh mục sản phẩm';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price and Stock Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Giá bán',
                      suffixText: 'đ',
                      labelStyle: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 15,
                        letterSpacing: -0.6,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey,),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bắt buộc';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Không hợp lệ :*(';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      labelText: 'Số lượng *',
                      labelStyle: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 15,
                        letterSpacing: -0.6,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey,),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bắt buộc';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Không hợp lệ :*(';
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
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Trạng thái',
                labelStyle: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 15,
                  letterSpacing: -0.6,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey,),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              items: [
                DropdownMenuItem(value: 'active', child: Text('Đang bán',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 15,
                    letterSpacing: -0.6,
                  ),)),
                DropdownMenuItem(value: 'hidden', child: Text('Ẩn',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 15,
                    letterSpacing: -0.6,
                  ),)),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        const SizedBox(height: 16),

        Text('Thêm hình ảnh/video',
            style: GoogleFonts.inter(
              color: Colors.grey[600],
              fontSize: 18,
              letterSpacing: -0.6,
              fontWeight: FontWeight.w500,
            ),
        ),

        const SizedBox(height: 16),

        // Media Grid
        if (_mediaItems.isNotEmpty)
          SizedBox(
            height: 120,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mediaItems.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _mediaItems.removeAt(oldIndex);
                  _mediaItems.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final item = _mediaItems[index];
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
                            child: Icon(Icons.videocam, size: 40, color: Colors.black),
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
                            icon: const Icon(Icons.close, size: 16, color: Colors.black),
                            color: Colors.white,
                            onPressed: () {
                              setState(() => _mediaItems.removeAt(index));
                            },
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
              onPressed: () => _pickMedia('image'),
              icon: const Icon(Icons.image, color: Colors.black,),
              label: Text('Thêm ảnh',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 15,
                  letterSpacing: -0.6,
                ),),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => _pickMedia('video'),
              icon: const Icon(Icons.videocam, color: Colors.black,),
              label: Text('Thêm video',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 15,
                  letterSpacing: -0.6,
                ),),
            ),
          ],
        ),

        const SizedBox(height: 24,),

        Text('Thông tin sản phẩm',
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