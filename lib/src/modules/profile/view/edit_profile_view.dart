import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/models/enums/user_status.dart';
import 'package:sneakerx/src/models/user.dart';
import 'package:sneakerx/src/modules/profile/dtos/update_user_request.dart';
import 'package:sneakerx/src/services/user_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class EditProfileView extends StatefulWidget {
  // Optional: Flag to know if we should pop back to checkout
  final bool isFromCheckout;

  const EditProfileView({Key? key, this.isFromCheckout = false}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  File? _avatarFile;
  User? _currentUserData;

  // Controllers
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  // Default Status
  UserStatus _selectedStatus = UserStatus.ACTIVE;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch latest data from API
      final user = await _userService.getUserDetail();

      if (user != null) {
        _currentUserData = user;

        // 2. Pre-fill the controllers
        _usernameCtrl.text = user.username ?? "";
        _fullNameCtrl.text = user.fullName ?? "";
        _emailCtrl.text = user.email ?? "";
        _phoneCtrl.text = user.phone ?? "";

        // 3. Pre-select status (if API returns null, default to ACTIVE)
        if(user.status != null) {
          _selectedStatus = user.status;
        }
      }
    } catch (e) {
      _showMessage("Lỗi tải thông tin: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUserData == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Prepare Request Object
      final request = UpdateUserRequest(
        userId: _currentUserData!.userId, // Use ID from loaded data
        username: _usernameCtrl.text,
        fullName: _fullNameCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
        status: _selectedStatus,
        avatar: _avatarFile, // Can be null
      );

      // 2. Call Service
      final updatedUser = await _userService.updateUserDetail(request);

      if (updatedUser != null) {
        _showMessage("Cập nhật hồ sơ thành công!");

        // 3. Update Provider (Optional but recommended to keep app state fresh)
        Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();

        // 4. Navigate back (Return 'true' if we came from checkout)
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      _showMessage("Lỗi cập nhật: ${e.toString().replaceAll("Exception: ", "")}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, backgroundColor: Colors.grey[800]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Chỉnh sửa hồ sơ", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading && _currentUserData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- 1. AVATAR SECTION ---
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade100,
                        // Logic: Show New File -> Show Network URL -> Show Placeholder
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : (_currentUserData?.avatarUrl != null && _currentUserData!.avatarUrl!.isNotEmpty
                            ? NetworkImage(_currentUserData!.avatarUrl!)
                            : null) as ImageProvider?,
                        child: (_avatarFile == null && (_currentUserData?.avatarUrl == null || _currentUserData!.avatarUrl!.isEmpty))
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black,
                        child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF86F4B5)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. FORM FIELDS ---
              _buildTextField("Username", _usernameCtrl, icon: Icons.alternate_email),
              const SizedBox(height: 16),
              _buildTextField("Họ và tên", _fullNameCtrl, icon: Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField("Email", _emailCtrl, icon: Icons.email_outlined, inputType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField("Số điện thoại", _phoneCtrl, icon: Icons.phone_android, inputType: TextInputType.phone),
              const SizedBox(height: 16),

              // --- 3. STATUS DROPDOWN ---
              // Note: Usually Users cannot ban themselves, but implemented as requested.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<UserStatus>(
                    value: _selectedStatus,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: UserStatus.values.map((UserStatus status) {
                      return DropdownMenuItem<UserStatus>(
                        value: status,
                        child: Row(
                          children: [
                            Icon(_getStatusIcon(status), size: 18, color: _getStatusColor(status)),
                            const SizedBox(width: 10),
                            Text(status.name, style: GoogleFonts.inter(fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (UserStatus? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedStatus = newValue);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- 4. SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF86F4B5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text("Lưu thay đổi", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: (value) => value!.isEmpty ? "Vui lòng nhập $label" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF86F4B5))),
      ),
    );
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.ACTIVE: return Colors.green;
      case UserStatus.BANNED: return Colors.red;
      case UserStatus.DELETED: return Colors.grey;
      default: return Colors.black;
    }
  }

  IconData _getStatusIcon(UserStatus status) {
    switch (status) {
      case UserStatus.ACTIVE: return Icons.check_circle_outline;
      case UserStatus.BANNED: return Icons.block;
      case UserStatus.DELETED: return Icons.delete_outline;
      default: return Icons.help_outline;
    }
  }
}