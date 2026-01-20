import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/models/shops.dart';
import 'package:sneakerx/src/modules/seller_info/dtos/update_shop_request.dart';
import 'package:sneakerx/src/services/media_service.dart'; // Ensure you have this
import 'package:sneakerx/src/services/shop_service.dart';

class EditShopInfoScreen extends StatefulWidget {
  const EditShopInfoScreen({Key? key}) : super(key: key);

  @override
  State<EditShopInfoScreen> createState() => _EditShopInfoScreenState();
}

class _EditShopInfoScreenState extends State<EditShopInfoScreen> {
  final ShopService _shopService = ShopService();
  final MediaService _mediaService = MediaService(); // Need this to upload avatar
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;

  Shop? _currentShop;
  File? _newLogoFile;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentShopData();
  }

  Future<void> _loadCurrentShopData() async {
    try {
      final shopRes = await _shopService.getCurrentUserShop();
      if (!shopRes.success || shopRes.data == null) {
        GlobalSnackbar.show(context, success: false, message: "Shop information not found");
        Navigator.pop(context);
      }

      final shopDetail = shopRes.data!;

      _currentShop = shopDetail.shop;
      _nameCtrl.text = shopDetail.shop.shopName;
      _descCtrl.text = shopDetail.shop.shopDescription ?? "";

    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: "Error loading data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newLogoFile = File(picked.path));
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentShop == null) return;

    setState(() => _isSaving = true);

    try {
      String? finalLogoUrl = _currentShop!.shopLogo;

      // 1. Upload new logo if selected
      if (_newLogoFile != null) {
        final uploadRes = await _mediaService.uploadShopAvatar(
            _newLogoFile, _currentShop!.shopId
        );

        if (uploadRes.success && uploadRes.data != null) {
          finalLogoUrl = uploadRes.data!; // Get the new URL string
        } else {
          throw Exception("Image upload failed: ${uploadRes.message}");
        }
      }

      // 2. Update Shop Details with the URL string
      final request = UpdateShopRequest(
        shopId: _currentShop!.shopId,
        shopName: _nameCtrl.text.trim(),
        shopDescription: _descCtrl.text.trim(),
        shopLogo: finalLogoUrl, // Send the URL string
      );

      final response = await _shopService.updateShop(request); // Assuming updateShop returns ApiResponse<Shop>

      if (response.success) {
        GlobalSnackbar.show(context, success: true, message: "Updated successfully!");
        if (mounted) Navigator.pop(context, true);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Shop Profile',
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- LOGO SECTION ---
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[200]!, width: 2),
                          image: _getAvatarImage() != null
                              ? DecorationImage(image: _getAvatarImage()!, fit: BoxFit.cover)
                              : null,
                        ),
                        child: _getAvatarImage() == null
                            ? const Icon(Icons.store, size: 40, color: Colors.grey)
                            : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text("Tap to change logo", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 30),

              // --- FORM FIELDS ---
              _buildTextField(
                controller: _nameCtrl,
                label: "Shop Name",
                hint: "Enter your shop name",
                icon: Icons.store_outlined,
                validator: (v) => v!.trim().isEmpty ? "Shop name required" : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _descCtrl,
                label: "Description",
                hint: "Tell customers about your shop...",
                icon: Icons.description_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 40),

              // --- SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Save Changes', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getAvatarImage() {
    if (_newLogoFile != null) return FileImage(_newLogoFile!);
    if (_currentShop?.shopLogo != null && _currentShop!.shopLogo.isNotEmpty) {
      return NetworkImage(_currentShop!.shopLogo);
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey[400], size: 20) : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 1)),
          ),
        ),
      ],
    );
  }
}