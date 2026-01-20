import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/models/user_address.dart';
import 'package:sneakerx/src/modules/profile/view/edit_address_view.dart';
import 'package:sneakerx/src/services/user_service.dart';
import 'package:sneakerx/src/utils/api_response.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class AddressManagementView extends StatefulWidget {
  final bool isFromCheckOut;
  const AddressManagementView({super.key, this.isFromCheckOut = false});

  @override
  State<AddressManagementView> createState() => _AddressManagementViewState();
}

class _AddressManagementViewState extends State<AddressManagementView> {
  final UserService _userService = UserService();

  late Future<ApiResponse<List<UserAddress>>> _addressFuture;

  @override
  void initState() {
    super.initState();
    _refreshAddresses();
  }

  void _refreshAddresses() {
    setState(() {
      _addressFuture = _userService.getAddresses();
    });
  }

  void _navigateToForm({UserAddress? address}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormView(existingAddress: address),
      ),
    );

    // If the form returns true (meaning a save happened), refresh the list
    if (result == true) {
      _refreshAddresses();
    }
  }
  //
  void _onAddressSelected(UserAddress address) {
    if (widget.isFromCheckOut) {
      // Return the selected address object to Checkout screen
      Navigator.pop(context, address);
    } else {
      _navigateToForm(address: address);
    }
  }
  
  
  Future<void> _deleteAddress(int addressId) async {
    try {
      final response = await _userService.deleteAddress(addressId);
      if(response.success && response.data != null) {
        GlobalSnackbar.show(context, success: true, message: "Delete address successfully");
        _refreshAddresses();
      } else {
        GlobalSnackbar.show(context, success: false, message: response.message);
      }
    } catch(e) {
      GlobalSnackbar.show(context, success: false, message: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser!.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Address Management", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppConfig.secondary100),
            onPressed: () => _navigateToForm(), // Add new address
          )
        ],
      ),
      body: FutureBuilder<ApiResponse<List<UserAddress>>>(
        future: _addressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.data!.isEmpty) {
            return _buildEmptyState();
          }

          final addresses = snapshot.data!.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildAddressCard(addresses[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConfig.primary100,
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAddressCard(UserAddress address) {
    return GestureDetector(
      onTap: () => _onAddressSelected(address),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.recipientName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (!widget.isFromCheckOut)
                  TextButton(
                    onPressed: () => _navigateToForm(address: address),
                    child: Text("Edit", style: TextStyle(color: AppConfig.secondary100)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(address.phone, style: TextStyle(color: Colors.grey[600])),
                IconButton(
                  onPressed: () => _deleteAddress(address.addressId),
                  icon: Icon(Icons.delete_forever, color: Colors.red,),
                )
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${address.addressLine}, ${address.ward}, ${address.district}, ${address.provinceOrCity}",
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                SizedBox(width: 10,),
                if(address.isDefault) Icon(Icons.location_on_rounded, color: Colors.red,)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("You have not had address yet", style: TextStyle(color: Colors.grey[600])),
          TextButton(
            onPressed: () => _navigateToForm(),
            child: Text("Add new address", style: TextStyle(color: AppConfig.secondary100)),
          )
        ],
      ),
    );
  }
}