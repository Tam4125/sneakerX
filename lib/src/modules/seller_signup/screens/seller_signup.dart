import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/config/app_config.dart'; // Assuming you have AppConfig
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/modules/seller_info/dtos/update_shop_request.dart';
import 'package:sneakerx/src/modules/seller_signup/dtos/create_shop_request.dart';
import 'package:sneakerx/src/screens/seller_main_screen.dart';
import 'package:sneakerx/src/services/media_service.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';


class SellerSignup extends StatefulWidget {
  const SellerSignup({Key? key}) : super(key: key);

  @override
  State<SellerSignup> createState() => _SellerSignupState();
}

class _SellerSignupState extends State<SellerSignup> {
  bool _isLoading = false;
  File? _shopLogo;
  final ShopService _shopService = ShopService();
  final MediaService _mediaService = MediaService();
  final TextEditingController _shopName = TextEditingController();
  final TextEditingController _shopDescription = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _shopLogo = File(picked.path));
    }
  }

  Future<void> _createShop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final request = CreateShopRequest(
          shopLogo: null,
          shopDescription: _shopDescription.text,
          shopName: _shopName.text
      );

      final response = await _shopService.createShop(request);
      if(!response.success || response.data == null) {
        GlobalSnackbar.show(context, success: false, message: "Create Shop Failed: ${response.message}");
        return;
      }

      final newShop = response.data!;

      if(_shopLogo != null) {
        try {
          final avatarResponse = await _mediaService.uploadShopAvatar(_shopLogo, newShop.shopId);
          if(!avatarResponse.success || avatarResponse.data == null) {
            GlobalSnackbar.show(context, success: false, message: "Upload avatar image failed {${avatarResponse.message}");
            return;
          }

          try {
            final updateRequest = UpdateShopRequest(
              shopId: newShop.shopId,
              shopName: newShop.shopName,
              shopDescription: newShop.shopDescription ?? "",
              shopLogo: avatarResponse.data!,
            );
            final updateResponse = await _shopService.updateShop(updateRequest);

            if(!updateResponse.success || updateResponse.data == null) {
              GlobalSnackbar.show(context, success: false, message: "Update avatar image failed {${updateResponse.message}");
              return;
            }

          } catch(e) {
            GlobalSnackbar.show(context, success: false, message: "Update avatar image failed {$e}");
          }

        } catch(e) {
          GlobalSnackbar.show(context, success: false, message: "Upload avatar image failed {$e}");
        }
      }

      // Refresh auth to get the up-to-date user information
      auth.tryAutoLogin();

      GlobalSnackbar.show(context, success: true, message: "Create Shop Successfully");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SellerMainScreen(initialIndex: 0,)),
              (route) => false
      );
    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: "Upload avatar image failed {$e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using a light theme color palette
    final primaryColor = AppConfig.primary200; // Or your primary color
    const secondaryColor = Colors.black87;

    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
              onPressed: () => Navigator.pop(context)
          ),
          title: Text(
            'Open Your Shop',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // --- Header / Logo Section ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Shop Branding",
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 110, height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[100],
                                border: Border.all(color: Colors.grey[200]!, width: 2),
                                image: _shopLogo != null
                                    ? DecorationImage(image: FileImage(_shopLogo!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: _shopLogo == null
                                  ? Icon(Icons.add_a_photo_outlined, size: 35, color: Colors.grey[400])
                                  : null,
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.edit, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _shopLogo != null ? "Change Logo" : "Upload Logo",
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- Form Fields ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Shop Name"),
                      _buildTextField(
                        controller: _shopName,
                        hint: "e.g. SneakerX",
                        icon: Icons.storefront,
                        validator: (v) => v!.trim().isEmpty ? "Shop name is required" : null,
                      ),

                      const SizedBox(height: 24),

                      _buildLabel("Description"),
                      _buildTextField(
                        controller: _shopDescription,
                        hint: "Tell us about your shop...",
                        icon: Icons.description_outlined,
                        maxLines: 5,
                        validator: (v) => v!.trim().isEmpty ? "Description is required" : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Spacing for bottom sheet
              ],
            ),
          ),
        ),

        // --- Bottom Action Bar ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                children: [
                  const TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createShop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                  'Register Shop',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8, top: 0),
            child: Icon(icon, color: Colors.grey[400], size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}