import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/seller/models/create_product_model.dart';
import 'package:sneakerx/src/modules/seller/models/create_variant_model.dart';
import 'package:sneakerx/src/modules/seller/models/update_product_request.dart';
import 'package:sneakerx/src/modules/seller/models/update_variant_request.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';


// --- HELPER CLASS ---
class VariantFormItem {
  int? id;  // Null for new variants, ID for existing
  String type; // "SIZE" or "COLOR"
  String? selectedValue; // "42" or "0xFFFF0000"
  TextEditingController priceCtrl = TextEditingController();
  TextEditingController stockCtrl = TextEditingController();

  VariantFormItem({
    this.id,
    this.type = "SIZE",
    this.selectedValue,
    String price = "",
    String stock = "",
  }) {
    priceCtrl.text = price;
    stockCtrl.text = stock;
  }
}

class MediaItem {
  final File? file;
  final String type;
  final String? remoteUrl;
  MediaItem({this.file, this.remoteUrl, required this.type});
}


class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ShopService _shopService = ShopService();
  final AppConfig _appConfig = AppConfig();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  // State
  int? _selectedCategoryId;
  String _selectedStatus = 'ACTIVE';
  bool _isLoading = false;

  // List
  List<MediaItem> _mediaItems = [];
  List<VariantFormItem> _variantItems = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final product = widget.product;

    // 1. Basic Info
    _nameController = TextEditingController(text: product.name);
    _descriptionController = TextEditingController(text: product.description);
    _selectedCategoryId = product.categoryId;
    _selectedStatus = "ACTIVE";

    // 2. Initialize Images (Map from ProductImage -> MediaItem)
    if(product.images.isNotEmpty) {
      _mediaItems = product.images.map(
          (img) => MediaItem(
            type: 'image',
            remoteUrl: img.imageUrl,
          )
      ).toList();
    }


    if (product.variants.isEmpty) {
      _variantItems = [VariantFormItem()];
    } else {
      _variantItems = product.variants.map(
              (variant) => VariantFormItem(
                id: variant.variantId,
                type: variant.variantType,
                selectedValue: variant.variantValue,
                price: variant.price.toString(),
                stock: variant.stock.toString()
          )
      ).toList();
    }

  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    // Dispose all dynamic controllers
    for (var v in _variantItems) {
      v.priceCtrl.dispose();
      v.stockCtrl.dispose();
    }
  }

  // --- ACTIONS ---
  Future<void> _pickMedia() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _mediaItems.add(MediaItem(
            file: File(image.path),
            type: 'image',
          ));
        });
      }
    } catch (e) {
      _showMessage('Error picking media: $e');
    }
  }

  void _addVariant() {
    setState(() {
      _variantItems.add(VariantFormItem());
    });
  }

  void _removeImage(int index) {
    if (_mediaItems.length > 1) {
      setState(() {
        _mediaItems.removeAt(index);
      });
    } else {
      _showMessage("Phải có ít nhất 1 hình ảnh");
    }
  }

  void _removeVariant(int index) {
    if (_variantItems.length > 1) {
      setState(() {
        _variantItems.removeAt(index);
      });
    } else {
      _showMessage("Phải có ít nhất 1 biến thể");
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate Variants manually (ensure values are picked)
    for (int i = 0; i < _variantItems.length; i++) {
      if (_variantItems[i].selectedValue == null) {
        _showMessage("Vui lòng chọn giá trị cho biến thể #${i + 1}");
        return;
      }
    }

    if (_mediaItems.isEmpty) {
      _showMessage('Vui lòng thêm ít nhất 1 hình ảnh');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;
      if (token == null) throw Exception("Chưa đăng nhập");

      // 1. Separate Images: Keep URLs vs New Files
      List<String> keepImageUrls = [];
      List<File> newImageFiles = [];

      for (var item in _mediaItems) {
        if (item.remoteUrl != null) {
          keepImageUrls.add(item.remoteUrl!);
        } else if (item.file != null) {
          newImageFiles.add(item.file!);
        }
      }

      // 2. Prepare Variant DTOs
      List<VariantUpdateDto> variantDtos = _variantItems.map((item) {
        return VariantUpdateDto(
          variantId: item.id,
          variantType: item.type, // "SIZE" or "COLOR"
          variantValue: item.selectedValue!, // "42" or "0xFF..."
          price: double.parse(item.priceCtrl.text),
          stock: int.parse(item.stockCtrl.text),
        );
      }).toList();

      if(!auth.hasShop) throw Exception("Chưa tạo shop");
      final int shopId = auth.shopId!;
      // 2. Call Service
      final request = UpdateProductRequest(
        shopId: shopId,
        name: _nameController.text,
        description: _descriptionController.text,
        status: _selectedStatus,
        categoryId: _selectedCategoryId!,
        variants: variantDtos, // Send as a list
        keepImageUrls: keepImageUrls,
        newImages: newImageFiles
      );
      final apiResponse = await _shopService.updateProduct(widget.product.productId, request);

      if (mounted) {
        _showMessage('Thêm sản phẩm thành công!');
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Light grey background
      appBar: AppBar(
        title: Text('Thêm Sản Phẩm', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else
            IconButton(icon: const Icon(Icons.check, color: Colors.blue), onPressed: _updateProduct),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle("Hình ảnh"),
            _buildMediaSection(),
            const SizedBox(height: 24),

            _buildSectionTitle("Thông tin chung"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildTextField(_nameController, "Tên sản phẩm"),
                  const SizedBox(height: 12),
                  _buildTextField(_descriptionController, "Mô tả", maxLines: 3),
                  const SizedBox(height: 12),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 12),
                  _buildStatusDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Biến thể & Giá"),
                TextButton.icon(
                  onPressed: _addVariant,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Thêm biến thể"),
                )
              ],
            ),

            // --- DYNAMIC VARIANT LIST ---
            ..._variantItems.asMap().entries.map((entry) {
              int idx = entry.key;
              VariantFormItem item = entry.value;
              return _buildVariantCard(item, idx);
            }).toList(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- VARIANT WIDGETS ---

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Trạng thái',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'ACTIVE', child: Text("Đang bán")),
        DropdownMenuItem(value: 'HIDDEN', child: Text("Ẩn")),
      ],
      onChanged: (v) => setState(() => _selectedStatus = v!),
    );
  }

  Widget _buildVariantCard(VariantFormItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Biến thể #${index + 1}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey[700])),
              if (_variantItems.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeVariant(index),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Row 1: Type & Value
          Row(
            children: [
              // 1. Type Dropdown (Size vs Color)
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: item.type,
                  decoration: _inputDecoration("Loại"),
                  items: const [
                    DropdownMenuItem(value: "SIZE", child: Text("Size")),
                    DropdownMenuItem(value: "COLOR", child: Text("Màu sắc")),
                  ],
                  onChanged: (val) {
                    setState(() {
                      item.type = val!;
                      item.selectedValue = null; // Reset value when type changes
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),

              // 2. Value Dropdown (Dynamic based on Type)
              Expanded(
                flex: 3,
                child: item.type == "SIZE"
                    ? _buildSizeDropdown(item)
                    : _buildColorDropdown(item),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Price & Stock
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: item.priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration("Giá", suffix: "đ"),
                  validator: (v) => (v == null || v.isEmpty) ? "Nhập giá" : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: item.stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Kho"),
                  validator: (v) => (v == null || v.isEmpty) ? "Nhập kho" : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {int maxLines = 1, bool isNumber = false, String? suffix}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: _inputDecoration(label, suffix: suffix),
      validator: (val) => (val == null || val.isEmpty) ? 'Bắt buộc' : null,
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Hình ảnh sản phẩm', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        const SizedBox(height: 16),

        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Total items = Existing Media List + 1 Add Button
            itemCount: _mediaItems.length + 1,
            itemBuilder: (ctx, index) {

              // --- 1. RENDER "ADD BUTTON" (Last Item) ---
              if (index == _mediaItems.length) {
                return GestureDetector(
                  onTap: () => _pickMedia(), // Ensure this method is defined in your class
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                        SizedBox(height: 4),
                        Text("Thêm", style: TextStyle(color: Colors.grey, fontSize: 12))
                      ],
                    ),
                  ),
                );
              }

              // --- 2. RENDER IMAGE ITEM (Old or New) ---
              final item = _mediaItems[index];

              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImageWidget(item), // <--- Logic separated here
                    ),
                  ),

                  // Delete Button (X)
                  Positioned(
                    top: 4,
                    right: 12, // Adjusted slightly to fit container margin
                    child: GestureDetector(
                      onTap: () => setState(() {
                        // Logic: Remove from the list.
                        // If it was a 'remoteUrl', it won't be sent in 'keepImageUrls'
                        // If it was a 'file', it won't be uploaded.
                        _mediaItems.removeAt(index);
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

// --- Helper to switch between Network and File Image ---
  Widget _buildImageWidget(MediaItem item) {
    if (item.remoteUrl != null && item.remoteUrl!.isNotEmpty) {
      // OLD IMAGE (From Backend)
      return Image.network(
        item.remoteUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (ctx, error, stackTrace) =>
        const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else if (item.file != null) {
      // NEW IMAGE (From Gallery)
      return Image.file(
        item.file!,
        fit: BoxFit.cover,
      );
    } else {
      // Fallback
      return const Center(child: Icon(Icons.image, color: Colors.grey));
    }
  }

  Widget _buildSizeDropdown(VariantFormItem item) {
    return DropdownButtonFormField<String>(
      value: item.selectedValue,
      decoration: _inputDecoration("Chọn Size"),
      items: _appConfig.sizeOptions.map((size) {
        return DropdownMenuItem(value: size, child: Text(size));
      }).toList(),
      onChanged: (val) => setState(() => item.selectedValue = val),
      validator: (v) => v == null ? "Chọn size" : null,
    );
  }

  Widget _buildColorDropdown(VariantFormItem item) {
    return DropdownButtonFormField<String>(
      value: item.selectedValue,
      decoration: _inputDecoration("Chọn Màu"),
      items: _appConfig.colorOptions.entries.map((entry) {
        // Parse hex string to Color object for visual dot
        Color colorDot = Color(int.parse(entry.key));

        return DropdownMenuItem(
          value: entry.key, // Saves the Hex String (e.g., 0xFFFF0000)
          child: Row(
            children: [
              Container(
                width: 16, height: 16,
                decoration: BoxDecoration(color: colorDot, shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!)),
              ),
              const SizedBox(width: 8),
              Text(entry.value), // Shows the Name (e.g., Đỏ)
            ],
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => item.selectedValue = val),
      validator: (v) => v == null ? "Chọn màu" : null,
    );
  }

  // --- COMMON WIDGETS ---

  InputDecoration _inputDecoration(String label, {String? suffix}) {
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      labelStyle: const TextStyle(fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      isDense: true,
    );
  }

  // (Include your previous _pickMedia, _buildMediaSection, _buildTextField, _buildCategoryDropdown helpers here...)
  // They remain largely the same, just visual tweaks.

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Danh mục',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 1, child: Text("Nike")),
        DropdownMenuItem(value: 2, child: Text("Adidas")),
        DropdownMenuItem(value: 3, child: Text("Puma")),
      ],
      onChanged: (v) => setState(() => _selectedCategoryId = v),
      validator: (v) => v == null ? "Chọn danh mục" : null,
    );
  }

}


