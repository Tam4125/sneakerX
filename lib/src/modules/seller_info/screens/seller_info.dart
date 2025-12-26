import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/modules/seller_dashboard/widgets/icon_button_widget.dart';
import 'package:sneakerx/src/modules/seller_info/screens/edit_seller_infor.dart';
import 'package:sneakerx/src/modules/seller_info/widgets/infofield.dart';
import 'package:sneakerx/src/modules/seller_info/widgets/number_format.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/services/user_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class SellerInfo extends StatefulWidget {
  const SellerInfo({Key? key}) : super(key: key);

  @override
  State<SellerInfo> createState() => _SellerInfo();
}

class _SellerInfo extends State<SellerInfo> {
  final UserService _userService = UserService();
  final ShopService _shopService = ShopService();

  bool _isLoading = true;

  String _shopName = "Shop name";
  String _shopDescription = "Shop description";
  String _shopLogoUrl = "Shop logo url";
  double _shopRating = 0;
  int _shopFollower = 0;
  String _shopAddress = "Shop address";
  String _shopEmail = "Shop email";
  String _shopPhone = "Shop phone number";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    try {
      final shop = await _shopService.getCurrentUserShop();
      final addresses = await _userService.getAddresses();

      // 2. Wrap updates in setState so the UI refreshes
      if (mounted) {
        setState(() {
          if (shop != null) {
            _shopName = shop.shopName;
            _shopDescription = shop.shopDescription ?? "";
            _shopLogoUrl = shop.shopLogo;
            _shopRating = shop.rating;
            _shopFollower = shop.followersCount;
          } else {
            _showMessage("Không tìm thấy thông tin Shop");
          }

          if (addresses != null && addresses.isNotEmpty) {
            final address = addresses.first;
            _shopPhone = address.phone;
            _shopAddress = '${address.addressLine}, ${address.ward}, ${address.district}, ${address.provinceOrCity}';
            _shopEmail = user?.email ?? "";
          }

          // Data loading finished
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage("Lỗi tải dữ liệu: $e");
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,

        leading: IconButtonWidget(
          icon: Icons.home,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MainScreen()
                )
            );
          },
        ),
        title:
        Text(
          'Thông tin Shop',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButtonWidget(
              onPressed: () async {
                // Wait for edit screen to return 'true'
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditShopInfoScreen())
                );

                // If returned true, reload data to show changes
                if (result == true) {
                  _initializeData();
                }
              },
              icon: Icons.edit)
        ],
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(),)
        : SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child:
        Padding(
          padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 60.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 72,
                    backgroundColor: Color(0xFF86F4B5),
                    child: CircleAvatar(
                      radius: 64.0, // Inner circle radius
                      backgroundImage: NetworkImage(_shopLogoUrl),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.store,
                        size: 24, color: Color(0xFF86F4B5)),
                  ),
                ],
              ),
              const SizedBox (height: 40,),
              Text(_shopName,
                style: GoogleFonts.robotoMono(
                  fontSize: 24,
                  letterSpacing: -1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox (height: 40),
              Container(
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFF86F4B5),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                        child: Infofield(
                          label: 'Đánh giá',
                          text: '$_shopRating/5.00',
                          labelIcons: Icons.star,
                          size: 20,
                        ),
                      ),
                    ),

                    Container(
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFF86F4B5),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Infofield(
                          label: 'Người theo dõi',
                          text: formatCount(_shopFollower),
                          labelIcons: Icons.person,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox (height: 20),

              Divider(),

              const SizedBox (height: 20),

              Infofield(
                label: 'Mô Tả Shop',
                text: _shopDescription ?? '',
                labelIcons: Icons.description,
              ),

              const SizedBox (height: 20),

              Divider(),

              const SizedBox (height: 20),

              Infofield(
                label: 'Địa chỉ của shop',
                text: _shopAddress,
                labelIcons: Icons.markunread_mailbox,
              ),
              const SizedBox (height: 20),

              Divider(),

              const SizedBox (height: 20),

              Infofield(
                label: 'Email',
                text: _shopEmail,
                labelIcons: Icons.mail,
              ),
              const SizedBox (height: 20),

              Divider(),


              const SizedBox (height: 20),

              Infofield(
                label: 'Số điện thoại',
                text: _shopPhone,
                labelIcons: Icons.phone_enabled,
              ),
            ],
          ),
        ),
      ),
      );
  }
}
