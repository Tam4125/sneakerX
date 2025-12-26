import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sneakerx/src/modules/seller_dashboard/widgets/icon_button_widget.dart';
import 'dart:io';
import 'package:sneakerx/src/modules/seller_signup/widgets/textfield.dart';

class SellerEdit extends StatefulWidget {
  const SellerEdit({Key? key}) : super(key: key);

  @override
  State<SellerEdit> createState() => _SellerEdit();
}

class _SellerEdit extends State<SellerEdit> {
  File? _image;
  late final TextEditingController _shopNameController;
  late final TextEditingController _shopDescriptionController;
  late final TextEditingController _addressLineController;
  late final TextEditingController _provinceOrCityController;
  late final TextEditingController _districtController;
  late final TextEditingController _wardController;
  late final TextEditingController _phoneController;
  ImageProvider? _prefilledAvatar;


  //YOU NEED TO KEEP GOING, NEXT IS TO PREFILL THESE TEXTCONTROLLERS WITH MOCK DATA AND PASS THEM IN THIS DART FILE.
  //THEN YOU ALSO HAVE 2 OTHER UI LEFT TO DO, GOOD LUCK.

  @override
  void initState() {
    super.initState();

    _shopNameController =
        TextEditingController(text: 'EATITUPTOYSTORE');

    _shopDescriptionController = TextEditingController(
      text: 'Shop chuyên bán đồ chơi mô hình, quà tặng và figure.',
    );

    _provinceOrCityController = TextEditingController(
      text: 'Thành Phố Hồ Chí Minh',
    );

    _districtController = TextEditingController(
      text: 'Quận 3'
    );

    _wardController = TextEditingController(
      text: 'Phường 14'
    );

    _addressLineController = TextEditingController(
      text: '108/38L'
    );

    _phoneController = TextEditingController(
      text: '0919206506'
    );

    _prefilledAvatar = const AssetImage('assets/images/sellerpic.jpg');
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _addressLineController.dispose();
    _provinceOrCityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _phoneController.dispose();
    super.dispose();
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
          'Sửa thông tin của Shop',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButtonWidget(
              onPressed: () => _showMessage('Lưu thành công!'),
              icon: Icons.save)
        ],
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
                const SizedBox(height: 30,),
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : _prefilledAvatar,
                        child: (_image == null && _prefilledAvatar == null)
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
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
                const SizedBox (height: 30),
                CustomTextField(
                  label: 'Tên Shop',
                  hint: 'Hãy nhập tên shop của bạn vào đây nhé',
                  controller: _shopNameController,
                ),
                const SizedBox(height: 30,),
                CustomTextField(
                  label: 'Số điện thoại',
                  hint: '+840967XXXXX',
                  controller: _phoneController,
                ),
                const SizedBox(height: 30,),
                CustomTextField(
                  label: 'Mô Tả Shop',
                  hint: 'Hãy nhập mô tả cho shop của bạn vào đây nhé',
                  controller: _shopDescriptionController,
                  isMultiline: true,
                  maxLines: 8,
                ),
                const SizedBox(height: 30,),
                CustomTextField(
                  label: 'Tỉnh/Thành Phố',
                  hint: 'Hãy nhập tỉnh/thành phố của shop vào đây nhé',
                  controller: _provinceOrCityController,
                ),
                const SizedBox(height: 30,),
                CustomTextField(
                  label: 'Quận',
                  hint: 'Hãy nhập quận của shop vào đây nhé',
                  controller: _districtController,
                ),
                const SizedBox(height: 30,),
                CustomTextField(
                  label: 'Phường',
                  hint: 'Hãy nhập phường của shop vào đây nhé',
                  controller: _wardController,
                ),
                const SizedBox(height: 30,),
                CustomTextField(
                  label: 'Địa chỉ',
                  hint: 'Hãy nhập địa chỉ của shop vào đây nhé',
                  controller: _addressLineController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
