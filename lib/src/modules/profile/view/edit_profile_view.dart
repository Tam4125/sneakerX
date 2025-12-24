import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_response.dart';
import 'package:sneakerx/src/modules/profile/dtos/create_user_address_request.dart';
import 'package:sneakerx/src/modules/profile/dtos/update_address_request.dart';
import 'package:sneakerx/src/services/user_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class EditProfileView extends StatefulWidget {
  final bool isFromCheckOut;
  const EditProfileView({Key? key, this.isFromCheckOut = false}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final Color primaryPurple = const Color(0xFF8B5FBF);
  final Color primaryGreen = const Color(0xFF86F4B5);
  final UserService _userService = UserService();
  bool _isFirst = false;
  int _addressId = -1;
  bool _isLoading = false;

  final TextEditingController _recipientName = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _provinceOrCity = TextEditingController();
  final TextEditingController _district = TextEditingController();
  final TextEditingController _ward = TextEditingController();
  final TextEditingController _addressLine = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    try {
      final addresses = await _userService.getAddresses();

      if (addresses != null && addresses.isNotEmpty) {
        final address = addresses.first;
        _addressId = address.addressId;

        // Update the text of the existing controllers
        _recipientName.text = address.recipientName;
        _phone.text = address.phone;
        _provinceOrCity.text = address.provinceOrCity;
        _district.text = address.district;
        _ward.text = address.ward;
        _addressLine.text = address.addressLine;
      } else {
        _isFirst = true;
        // Controllers are already empty by default, so no action needed
      }
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      // Turn off loading when done
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _recipientName.dispose();
    _phone.dispose();
    _provinceOrCity.dispose();
    _district.dispose();
    _ward.dispose();
    _addressLine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;


    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, user!),
            _buildFormBody(context),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HEADER GRADIENT ---
  Widget _buildHeader(BuildContext context, UserSignInResponse user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryGreen, Colors.white],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Thanh AppBar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              const Text("Địa chỉ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black87),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 10),

          // AVATAR và THÔNG TIN
          Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(user.avatarUrl), // Ảnh mẫu
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryPurple, // Icon camera màu tím
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Tên người dùng
              Text(
                user.username,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              // Dòng chữ nhỏ
              Text(
                "Cập nhật địa chỉ",
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET FORM (Nền trắng bo góc) ---
  Widget _buildFormBody(BuildContext context) {
    // Dùng Transform.translate để đẩy Container lên đè vào phần Header
    return Transform.translate(
      offset: const Offset(0, -25), // Đẩy lên 25px
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Bo góc tròn ở trên
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Các trường nhập liệu
            _buildLabel("Tên người nhận", isRequired: true),
            _buildInputField(controller: _recipientName, icon: Icons.person_outline, hint: "Nhập tên người nhận"),

            const SizedBox(height: 20),
            _buildLabel("Số điện thoại", isRequired: true),
            _buildInputField(controller: _phone, icon: Icons.phone_outlined, inputType: TextInputType.emailAddress, hint: "Nhập số điện thoại"),

            const SizedBox(height: 20),
            _buildLabel("Tỉnh/Thành phố", isRequired: true),
            _buildInputField(controller: _provinceOrCity, icon: Icons.location_city, inputType: TextInputType.phone, hint: "Nhập tỉnh/thành phố"),

            const SizedBox(height: 20),
            _buildLabel("Quận", isRequired: true),
            _buildInputField(controller: _district, icon: Icons.location_city, isPassword: true, hint: "Nhập quận"),

            const SizedBox(height: 20),
            _buildLabel("Phường", isRequired: true),
            _buildInputField(controller: _ward, icon: Icons.location_city, hint: "Nhập phường"),

            const SizedBox(height: 20),
            _buildLabel("Đường", isRequired: true),
            _buildInputField(controller: _addressLine, icon: Icons.location_city, hint: "Nhập tên đường"),

            // const SizedBox(height: 20),
            //
            // // Hàng Ngày sinh & Giới tính
            // Row(
            //   children: [
            //     Expanded(child: _buildDateField(context)),
            //     const SizedBox(width: 15),
            //     Expanded(child: _buildGenderField()),
            //   ],
            // ),

            const SizedBox(height: 40),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 55,
              child: _isLoading
                ? Center(child: CircularProgressIndicator(),)
                : ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple, // Màu tím
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  shadowColor: primaryPurple.withOpacity(0.4),
                ),
                child: const Text("Lưu thay đổi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON NHỎ ---
  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
          children: [
            if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100], // Nền xám nhạt cho ô nhập
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: false,
        keyboardType: inputType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ),
    );
  }

  // Widget _buildDateField(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildLabel("Ngày sinh"),
  //       InkWell(
  //         onTap: () => _selectDate(context),
  //         child: Container(
  //           height: 55,
  //           padding: const EdgeInsets.symmetric(horizontal: 15),
  //           decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
  //               Icon(Icons.calendar_today, size: 18, color: Colors.grey[500]),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // Widget _buildGenderField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildLabel("Giới tính"),
  //       Container(
  //         height: 55,
  //         padding: const EdgeInsets.symmetric(horizontal: 10),
  //         decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
  //         child: DropdownButtonHideUnderline(
  //           child: DropdownButton<String>(
  //             value: _gender,
  //             isExpanded: true,
  //             icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
  //             items: ["Nam", "Nữ", "Khác"].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
  //             onChanged: (val) => setState(() => _gender = val!),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate,
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime.now(),
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           colorScheme: ColorScheme.light(primary: primaryPurple, onPrimary: Colors.white, onSurface: Colors.black),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null) setState(() => _selectedDate = picked);
  // }

  void _handleSave() async {
    setState(() {
      _isLoading = true;
    });
    if(_isFirst) {
      CreateUserAddressRequest request = CreateUserAddressRequest(
          recipientName: _recipientName.text,
          phone: _phone.text,
          provinceOrCity: _provinceOrCity.text,
          district: _district.text,
          ward: _ward.text,
          addressLine: _addressLine.text
      );

      final newAddress = await _userService.createAddress(request);

      setState(() {
        _isLoading = false;
      });

      if(newAddress != null) {
        _showMessage("Create address successfully");
      } else {
        _showMessage("Create address failed");
      }
    } else {
      UpdateAddressRequest request = UpdateAddressRequest(
        addressId: _addressId,
        recipientName: _recipientName.text,
        phone: _phone.text,
        provinceOrCity: _provinceOrCity.text,
        district: _district.text,
        ward: _ward.text,
        addressLine: _addressLine.text
      );

      final newAddress = await _userService.updateAddress(request);

      setState(() {
        _isLoading = false;
      });

      if(newAddress != null) {
        _showMessage("Update address successfully");

        if (widget.isFromCheckOut) {
          // Return 'true' to signal CheckoutView to reload
          Navigator.pop(context, true);
        }

      } else {
        _showMessage("Update address failed");
      }
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
}