import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/seller/models/create_product_model.dart';
import 'package:sneakerx/src/modules/seller/models/create_variant_model.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';


// --- HELPER CLASS TO MANAGE UI STATE FOR EACH VARIANT ---
class VariantFormItem {
  String type; // "SIZE" or "COLOR"
  String? selectedValue; // "42" or "0xFFFF0000"
  TextEditingController priceCtrl = TextEditingController();
  TextEditingController stockCtrl = TextEditingController();

  VariantFormItem({
    this.type = "SIZE",
    this.selectedValue,
  });
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreen();
}

class _AddProductScreen extends State<AddProductScreen> {
  final ShopService _shopService = ShopService();
  final AppConfig _appConfig = AppConfig();
  final _formKey = GlobalKey<FormState>();

  // Basic Product Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // State
  int? _selectedCategoryId;
  String _selectedStatus = 'ACTIVE';
  List<MediaItem> _mediaItems = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // --- DYNAMIC VARIANTS STATE ---
  // Start with 1 empty variant
  List<VariantFormItem> _variantItems = [VariantFormItem()];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    // Dispose all dynamic controllers
    for (var v in _variantItems) {
      v.priceCtrl.dispose();
      v.stockCtrl.dispose();
    }
    super.dispose();
  }

  // --- MEDIA PICKER LOGIC  ---
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
      }
    } catch (e) {
      _showMessage('Error picking media: $e');
    }
  }

  // --- ACTIONS ---

  void _addVariant() {
    setState(() {
      _variantItems.add(VariantFormItem());
    });
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

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate Variants manually (ensure values are picked)
    for (int i = 0; i < _variantItems.length; i++) {
      if (_variantItems[i].selectedValue == null) {
        _showMessage("Vui lòng chọn giá trị cho biến thể #${i + 1}");
        return;
      }
    }

    // if (_mediaItems.isEmpty) {
    //   _showMessage('Vui lòng thêm ít nhất 1 hình ảnh');
    //   return;
    // }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;
      if (token == null) throw Exception("Chưa đăng nhập");

      // 1. Convert UI Items to DTOs
      List<CreateVariantRequest> variantDtos = _variantItems.map((item) {
        return CreateVariantRequest(
          variantType: item.type, // "SIZE" or "COLOR"
          variantValue: item.selectedValue!, // "42" or "0xFF..."
          price: double.parse(item.priceCtrl.text),
          stock: int.parse(item.stockCtrl.text),
        );
      }).toList();

      List<File> imageFiles = _mediaItems.map((m) => m.file).toList();

      if(!auth.hasShop) throw Exception("Chưa tạo shop");
      final int shopId = auth.shopId!;
      // 2. Call Service
      final request = CreateProductRequest(
        shopId: shopId,
        name: _nameController.text,
        description: _descriptionController.text,
        status: _selectedStatus,
        categoryId: _selectedCategoryId!,
        variants: variantDtos, // Send as a list
        images: imageFiles,
      );
      Product? newProduct = await _shopService.createProduct(request);

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
            IconButton(icon: const Icon(Icons.check, color: Colors.blue), onPressed: _saveProduct),
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
      children: [
        const SizedBox(height: 16),
        Text('Thêm hình ảnh', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        const SizedBox(height: 16),

        // Horizontal Scroll List
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _mediaItems.length + 1, // +1 for the "Add" button
            itemBuilder: (ctx, index) {
              if (index == _mediaItems.length) {
                // Add Button
                return GestureDetector(
                  onTap: () => _pickMedia('image'),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo, color: Colors.grey),
                        SizedBox(height: 4),
                        Text("Thêm", style: TextStyle(color: Colors.grey, fontSize: 12))
                      ],
                    ),
                  ),
                );
              }

              // Image Item
              final item = _mediaItems[index];
              return Stack(
                children: [
                  Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(item.file, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 4, right: 12,
                    child: GestureDetector(
                      onTap: () => setState(() => _mediaItems.removeAt(index)),
                      child: const CircleAvatar(
                        radius: 10, backgroundColor: Colors.white,
                        child: Icon(Icons.close, size: 14, color: Colors.red),
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

class MediaItem {
  final File file;
  final String type;
  final String path;
  MediaItem({required this.file, required this.type, required this.path});
}
