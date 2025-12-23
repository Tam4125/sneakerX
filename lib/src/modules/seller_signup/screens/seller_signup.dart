import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/modules/seller/widgets/seller/icon_button_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sneakerx/src/modules/seller_signup/widgets/textfield.dart';

class SellerSignup extends StatefulWidget {
   const SellerSignup({Key? key}) : super(key: key);

   @override
   State<SellerSignup> createState() => _SellerSignup();
 }

class _SellerSignup extends State<SellerSignup> {
  String _activeTab = 'products';
  File? _image;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked =
    await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
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
             _showMessage('its printed!');
           }
         ),
         title:
         Text(
           'Đăng ký mở Shop',
           style: GoogleFonts.inter(
             fontSize: 18,
             fontWeight: FontWeight.w500,
             letterSpacing: -1,
           ),
         ),
       ),
      body:
      SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child:
      Padding(
        padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 60.0),
        child:
      Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Ảnh đại diện',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const SizedBox(height:20),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                    _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? const Icon(Icons.person,
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
            const SizedBox (height: 50),
            CustomTextField(
                label: 'Tên Shop',
                hint: 'Hãy nhập tên shop của bạn vào đây nhé'
            ),
            const SizedBox(height: 30,),
            CustomTextField(
                label: 'Số điện thoại',
                hint: '+840967XXXXX'
            ),
            const SizedBox(height: 30,),
            CustomTextField(
                label: 'Mô Tả Shop',
                hint: 'Hãy nhập mô tả cho shop của bạn vào đây nhé',
                isMultiline: true,
                maxLines: 8,
            ),
            const SizedBox(height: 30,),
            CustomTextField(
                label: 'Tỉnh/Thành Phố',
                hint: 'Hãy nhập tỉnh/thành phố của shop vào đây nhé'
            ),
            const SizedBox(height: 30,),
            CustomTextField(
                label: 'Quận',
                hint: 'Hãy nhập quận của shop vào đây nhé'
            ),
            const SizedBox(height: 30,),
            CustomTextField(
                label: 'Phường',
                hint: 'Hãy nhập phường của shop vào đây nhé'
            ),
            const SizedBox(height: 30,),
            CustomTextField(
                label: 'Địa chỉ',
                hint: 'Hãy nhập địa chỉ của shop vào đây nhé'
            ),
          ],
        ),

      ),
      ),
      ),
      bottomNavigationBar:
          Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200, // Shadow color and opacity
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Bottom shadow
                ),
              ],
            ),
            child:
            Column(
              children: [
                const SizedBox(height: 10,),
                Text('Bằng cách nhấn "Đăng ký", bạn đồng ý với các điều khoản của chúng tôi.',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                  letterSpacing: -0.3,
                ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF86F4B5),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),),
                  ),
                  onPressed: () => _showMessage('Đăng ký mở shop thành công!'),
                  child: Text(
                    'Đăng ký',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 28,
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
