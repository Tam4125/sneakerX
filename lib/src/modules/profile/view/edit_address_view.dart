import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/models/user_address.dart';
import 'package:sneakerx/src/modules/profile/dtos/create_user_address_request.dart';
import 'package:sneakerx/src/modules/profile/dtos/update_address_request.dart';
import 'package:sneakerx/src/services/user_service.dart';

class AddressFormView extends StatefulWidget {
  final UserAddress? existingAddress; // Null if adding new, populated if editing

  const AddressFormView({super.key, this.existingAddress});

  @override
  State<AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<AddressFormView> {
  final UserService _userService = UserService();
  bool _isLoading = false;

  final TextEditingController _recipientName = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _provinceOrCity = TextEditingController();
  final TextEditingController _district = TextEditingController();
  final TextEditingController _ward = TextEditingController();
  final TextEditingController _addressLine = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.existingAddress != null) {
      // Update mode: Pre-fill data
      final addr = widget.existingAddress!;
      _recipientName.text = addr.recipientName;
      _phone.text = addr.phone;
      _provinceOrCity.text = addr.provinceOrCity;
      _district.text = addr.district;
      _ward.text = addr.ward;
      _addressLine.text = addr.addressLine;
      _isDefault = addr.isDefault;
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
    bool isUpdateMode = widget.existingAddress != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isUpdateMode ? "Address Update" : "Add New Address", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Recipient name", isRequired: true),
            _buildInputField(controller: _recipientName, icon: Icons.person_outline, hint: "Nhập tên người nhận"),

            const SizedBox(height: 20),
            _buildLabel("Phone number", isRequired: true),
            _buildInputField(controller: _phone, icon: Icons.phone_outlined, inputType: TextInputType.phone, hint: "Nhập số điện thoại"),

            const SizedBox(height: 20),
            _buildLabel("City/Province", isRequired: true),
            _buildInputField(controller: _provinceOrCity, icon: Icons.location_city, hint: "Nhập tỉnh/thành phố"),

            const SizedBox(height: 20),
            _buildLabel("District", isRequired: true),
            _buildInputField(controller: _district, icon: Icons.map_outlined, hint: "Nhập quận/huyện"),

            const SizedBox(height: 20),
            _buildLabel("Ward", isRequired: true),
            _buildInputField(controller: _ward, icon: Icons.holiday_village, hint: "Nhập phường/xã"),

            const SizedBox(height: 20),
            _buildLabel("Address line", isRequired: true),
            _buildInputField(controller: _addressLine, icon: Icons.home_outlined, hint: "Nhập tên đường"),

            const SizedBox(height: 20),

            // --- NEW: Default Address Switch ---
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!)
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                activeColor: AppConfig.secondary100,
                title: Text("Set as default address", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                value: _isDefault,
                onChanged: (bool value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.secondary100,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: Text(isUpdateMode ? "Save" : "Add new address", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets (Kept same as your code) ---
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
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          hintText: hint,
        ),
      ),
    );
  }

  void _handleSave() async {
    // Basic Validation
    if (_recipientName.text.isEmpty || _phone.text.isEmpty || _addressLine.text.isEmpty) {
      GlobalSnackbar.show(context, success: false, message: "Please fully enter information");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.existingAddress == null) {
        // --- CREATE NEW ---
        CreateUserAddressRequest request = CreateUserAddressRequest(
            recipientName: _recipientName.text,
            phone: _phone.text,
            provinceOrCity: _provinceOrCity.text,
            district: _district.text,
            ward: _ward.text,
            addressLine: _addressLine.text,
            isDefault: _isDefault
        );

        final response = await _userService.createAddress(request);
        if (response.success && response.data != null) {
          GlobalSnackbar.show(context, success: true, message: "Adding new address successfully");
          if(mounted) Navigator.pop(context, true); // Return true to refresh list
        } else {
          GlobalSnackbar.show(context, success: false, message: "Adding new address failed");
        }
      } else {
        // --- UPDATE EXISTING ---
        UpdateAddressRequest request = UpdateAddressRequest(
            addressId: widget.existingAddress!.addressId, // Use ID from object
            recipientName: _recipientName.text,
            phone: _phone.text,
            provinceOrCity: _provinceOrCity.text,
            district: _district.text,
            ward: _ward.text,
            addressLine: _addressLine.text,
            isDefault: _isDefault
        );

        final response = await _userService.updateAddress(request);
        if (response.success && response.data != null) {
          GlobalSnackbar.show(context, success: true, message: "Update address successfully");
          if(mounted) Navigator.pop(context, true); // Return true to refresh list
        } else {
          GlobalSnackbar.show(context, success: false, message: "Update address failed");
        }
      }
    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: "Service Error: $e");
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }
}