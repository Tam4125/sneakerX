import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/models/shops.dart';
import 'package:sneakerx/src/modules/seller_dashboard/widgets/icon_button_widget.dart';
import 'package:sneakerx/src/modules/seller_signup/dtos/create_shop_request.dart';
import 'dart:io';
import 'package:sneakerx/src/modules/seller_signup/widgets/textfield.dart';
import 'package:sneakerx/src/screens/seller_main_screen.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class SellerSignup extends StatefulWidget {
  const SellerSignup({Key? key}) : super(key: key);

  @override
  State<SellerSignup> createState() => _SellerSignup();
}

class _SellerSignup extends State<SellerSignup> {
  bool _isLoading = false;
  File? _shopLogo;
  final ShopService _shopService = ShopService();
  final TextEditingController _shopName = TextEditingController();
  final TextEditingController _shopDescription = TextEditingController();

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _shopLogo = File(picked.path);
      });
    }
  }

  Future<void> _createShop() async {
    // 1. Validation
    if (_shopName.text.trim().isEmpty) {
      _showMessage("Vui lòng nhập tên Shop");
      return;
    }
    if (_shopDescription.text.trim().isEmpty) {
      _showMessage("Vui lòng nhập mô tả Shop");
      return;
    }

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 2. Call Service
      final request = CreateShopRequest(
          shopLogo: _shopLogo, // Can be null (backend handles default)
          shopDescription: _shopDescription.text,
          shopName: _shopName.text
      );

      Shop? newShop = await _shopService.createShop(request);

      if (mounted && newShop != null) {
        _showMessage('Đăng ký shop thành công!');

        // 3. Update Provider status
        await auth.refreshShopStatus();

        // 4. Navigate to Seller Dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SellerMainScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      _showMessage(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButtonWidget(
            icon: Icons.arrow_back,
            onPressed: () {
              Navigator.pop(context);
            }
        ),
        title: Text(
          'Đăng ký mở Shop',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 60.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Ảnh đại diện',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                        _shopLogo != null ? FileImage(_shopLogo!) : null,
                        child: _shopLogo == null
                            ? const Icon(Icons.store,
                            size: 40, color: Colors.white)
                            : null,
                      ),
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.edit,
                            size: 14, color: Color(0xFF86F4B5)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // --- FORM FIELDS ---
                CustomTextField(
                    controller: _shopName,
                    label: 'Tên Shop',
                    hint: 'Nhập tên shop của bạn'
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _shopDescription,
                  label: 'Mô Tả Shop',
                  hint: 'Giới thiệu ngắn gọn về shop...',
                  isMultiline: true,
                  maxLines: 8,
                ),

              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'Bằng cách nhấn "Đăng ký", bạn đồng ý với các điều khoản của chúng tôi.',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF86F4B5),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              // CONNECTED THE BUTTON
              onPressed: _isLoading ? null : _createShop,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                'Đăng ký',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: -1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}