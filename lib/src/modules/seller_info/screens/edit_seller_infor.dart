import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sneakerx/src/models/shops.dart';
import 'package:sneakerx/src/modules/seller_dashboard/widgets/icon_button_widget.dart';
import 'package:sneakerx/src/modules/seller_info/dtos/update_shop_request.dart';
import 'package:sneakerx/src/services/shop_service.dart';

class EditShopInfoScreen extends StatefulWidget {
  const EditShopInfoScreen({Key? key}) : super(key: key);

  @override
  State<EditShopInfoScreen> createState() => _EditShopInfoScreenState();
}

class _EditShopInfoScreenState extends State<EditShopInfoScreen> {
  final ShopService _shopService = ShopService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;

  // Data Holders
  Shop? _currentShop;
  File? _newLogoFile;

  // Controllers
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentShopData();
  }

  // 1. LOAD DATA ON START
  Future<void> _loadCurrentShopData() async {
    try {
      final shop = await _shopService.getCurrentUserShop();
      if (shop != null) {
        _currentShop = shop;
        _nameCtrl.text = shop.shopName;
        _descCtrl.text = shop.shopDescription ?? "";
      } else {
        _showMessage("Không tìm thấy thông tin Shop");
        Navigator.pop(context); // Exit if no shop found
      }
    } catch (e) {
      _showMessage("Lỗi tải dữ liệu: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. PICK IMAGE LOGIC
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _newLogoFile = File(picked.path);
      });
    }
  }

  // 3. SAVE LOGIC
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentShop == null) return;

    setState(() => _isSaving = true);

    try {
      // Create Request Object
      final request = UpdateShopRequest(
        shopId: _currentShop!.shopId,
        shopName: _nameCtrl.text.trim(),
        shopDescription: _descCtrl.text.trim(),
        shopLogo: _newLogoFile, // Can be null if user didn't change it
      );

      // Call your Service
      // Note: I assumed the method name is updateUserDetail based on your prompt,
      // but logically it should probably be updateShopDetail. Check your service file.
      final updatedShop = await _shopService.updateUserDetail(request);

      if (updatedShop != null) {
        _showMessage("Cập nhật thành công!");
        Navigator.pop(context, true); // Return true to trigger refresh on previous screen
      }
    } catch (e) {
      _showMessage(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButtonWidget(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chỉnh sửa Shop',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- LOGO SECTION ---
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF86F4B5), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        // Logic: Show New File -> Show Network URL -> Show Icon
                        backgroundImage: _getAvatarImage(),
                        child: _getAvatarChild(),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black,
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Color(0xFF86F4B5)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- NAME FIELD ---
              _buildTextField(
                controller: _nameCtrl,
                label: "Tên Shop",
                icon: Icons.store,
                validator: (val) => val!.isEmpty ? "Tên shop không được để trống" : null,
              ),
              const SizedBox(height: 20),

              // --- DESCRIPTION FIELD ---
              _buildTextField(
                controller: _descCtrl,
                label: "Mô tả",
                icon: Icons.description,
                maxLines: 5,
              ),
              const SizedBox(height: 40),

              // --- SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF86F4B5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Lưu thay đổi',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to determine Image Provider
  ImageProvider? _getAvatarImage() {
    if (_newLogoFile != null) {
      return FileImage(_newLogoFile!);
    } else if (_currentShop?.shopLogo != null && _currentShop!.shopLogo.isNotEmpty) {
      return NetworkImage(_currentShop!.shopLogo);
    }
    return null;
  }

  // Helper for empty state icon
  Widget? _getAvatarChild() {
    if (_newLogoFile == null && (_currentShop?.shopLogo == null || _currentShop!.shopLogo.isEmpty)) {
      return const Icon(Icons.store, size: 50, color: Colors.grey);
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF86F4B5)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}