import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:snkrxx/data/database_helper.dart';
import 'package:snkrxx/models/product.dart';
import 'package:snkrxx/models/product_media.dart';
import 'package:snkrxx/widgets/icon_button_widget.dart';
import 'package:snkrxx/widgets/product_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class EditProductScreen extends StatefulWidget {
  final int productId;
  final int shopId;

  const EditProductScreen({
    Key? key,
    required this.productId,
    required this.shopId,
  }) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreen();
}

class _EditProductScreen extends State<EditProductScreen> {
  List<ProductMedia> mediaList = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  late Future<Product> _productFuture;

  Product? _product;
  int? _selectedCategoryId;
  String _selectedStatus = 'active';
  List<MediaItem> _mediaItems = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
    _loadMedia();
  }

  Future<void> _loadProduct() async {
    _productFuture = DatabaseHelper().getProductById(widget.productId);
  }

  Future<void> _loadMedia() async {
    final result = await DatabaseHelper()
        .getMediaByProductId(widget.productId);

    setState(() {
      mediaList = result;
    });
  }

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
      _showMessage('Lỗi khi chọn file: $e');
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa', style: GoogleFonts.inter(fontSize: 11)),
        content: Text('Bồ có chắc muốn xóa sản phẩm này không?', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w200)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: GoogleFonts.inter(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await DatabaseHelper().deleteProduct(widget.productId);
      _showMessage('Đã xóa sản phẩm!');
      context.go('/productlist/${widget.shopId}');
    } catch (e) {
      _showMessage('Lỗi khi xóa sản phẩm: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedProduct = Product(
        productId: widget.productId,
        shopId: widget.shopId,
        categoryId: _selectedCategoryId!,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        soldCount: _product?.soldCount ?? 0,
        rating: _product?.rating ?? 0.0,
        status: _selectedStatus,
        createdAt: _product?.createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await DatabaseHelper().updateProduct(updatedProduct);

      // Save new media files
      for (int i = 0; i < _mediaItems.length; i++) {
        final media = _mediaItems[i];
        final productMedia = ProductMedia(
          productId: widget.productId,
          mediaUrl: media.path,
          mediaType: media.type,
          sortOrder: mediaList.length + i,
        );
        await DatabaseHelper().insertProductMedia(productMedia);
      }

      _showMessage('Đã cập nhật thành công!');
      context.pop();
    } catch (e) {
      _showMessage('Lỗi rồi bro :-( : $e');
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
          'Sửa sản phẩm',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProduct,
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy sản phẩm'));
          }

          final product = snapshot.data!;

          // Pre-fill form only once
          if (_product == null) {
            _product = product;
            _nameController.text = product.name;
            _descriptionController.text = product.description ?? '';
            _priceController.text = product.price.toString();
            _stockController.text = product.stock.toString();
            _selectedCategoryId = product.categoryId;
            _selectedStatus = product.status;
          }

          return ProductFormWidget(
            formKey: _formKey,
            nameController: _nameController,
            descriptionController: _descriptionController,
            priceController: _priceController,
            stockController: _stockController,
            selectedCategoryId: _selectedCategoryId,
            selectedStatus: _selectedStatus,
            mediaItems: _mediaItems,
            onCategoryChanged: (value) {
              setState(() => _selectedCategoryId = value);
            },
            onStatusChanged: (value) {
              setState(() => _selectedStatus = value);
            },
            onPickMedia: _pickMedia,
            onMediaReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _mediaItems.removeAt(oldIndex);
                _mediaItems.insert(newIndex, item);
              });
            },
            onMediaRemove: (index) {
              setState(() => _mediaItems.removeAt(index));
            },
          );
        },
      ),
    );
  }
}
