import 'package:flutter/material.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final Color primaryPurple = const Color(0xFF8B5FBF);
  final Color primaryGreen = const Color(0xFF86F4B5);

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _passwordController;

  String _gender = "Nam";
  DateTime _selectedDate = DateTime(2000, 1, 1);
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Dữ liệu giả lập ban đầu
    _nameController = TextEditingController(text: "Huỳnh Trần Thế Ngọc");
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER GRADIENT (Chứa Avatar và Tên)
            _buildHeader(context),

            // 2. FORM NHẬP LIỆU (Nền trắng bo góc)
            _buildFormBody(context),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HEADER GRADIENT ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 40, // Tạo khoảng trống bên dưới cho phần form bo lên
      ),
      // --- GRADIENT CHỦ ĐẠO CỦA BẠN ---
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
              const Text("Hồ Sơ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              // Nút menu giả (có thể bỏ)
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
                    child: const CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage("assets/images/ngoc.jpg"), // Ảnh mẫu
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
                _nameController.text.isEmpty ? "Chưa cập nhật tên" : _nameController.text,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              // Dòng chữ nhỏ
              Text(
                "Cập nhật thông tin cá nhân",
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
            _buildLabel("Họ và Tên", isRequired: true),
            _buildInputField(controller: _nameController, icon: Icons.person_outline, hint: "Nhập họ tên"),

            const SizedBox(height: 20),
            _buildLabel("Email", isRequired: true),
            _buildInputField(controller: _emailController, icon: Icons.email_outlined, inputType: TextInputType.emailAddress, hint: "Nhập email"),

            const SizedBox(height: 20),
            _buildLabel("Số điện thoại", isRequired: true),
            _buildInputField(controller: _phoneController, icon: Icons.phone_outlined, inputType: TextInputType.phone, hint: "Nhập số điện thoại"),

            const SizedBox(height: 20),
            _buildLabel("Mật khẩu", isRequired: true),
            _buildInputField(controller: _passwordController, icon: Icons.lock_outline, isPassword: true, hint: "Nhập mật khẩu"),

            const SizedBox(height: 20),
            _buildLabel("Địa chỉ", isRequired: true),
            _buildInputField(controller: _addressController, icon: Icons.location_on_outlined, maxLines: 2, hint: "Nhập địa chỉ"),

            const SizedBox(height: 20),

            // Hàng Ngày sinh & Giới tính
            Row(
              children: [
                Expanded(child: _buildDateField(context)),
                const SizedBox(width: 15),
                Expanded(child: _buildGenderField()),
              ],
            ),

            const SizedBox(height: 40),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
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
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: inputType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Ngày sinh"),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[500]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Giới tính"),
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _gender,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
              items: ["Nam", "Nữ", "Khác"].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
              onChanged: (val) => setState(() => _gender = val!),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryPurple, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _handleSave() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty || _addressController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng điền các mục bắt buộc (*)"), backgroundColor: Colors.redAccent));
      return;
    }
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Đã lưu hồ sơ thành công!"),
          backgroundColor: primaryPurple,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
    );
  }
}