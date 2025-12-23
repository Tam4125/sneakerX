import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/modules/seller/widgets/seller/icon_button_widget.dart';
import 'package:sneakerx/src/modules/seller_info/widgets/infofield.dart';
import 'package:sneakerx/src/modules/seller_signup/mockdata/mock_shop_data.dart';
import 'package:sneakerx/src/modules/seller_info/widgets/number_format.dart';

class SellerInfo extends StatefulWidget {
  const SellerInfo({Key? key}) : super(key: key);

  @override
  State<SellerInfo> createState() => _SellerInfo();
}

class _SellerInfo extends State<SellerInfo> {
  String _activeTab = 'products';
  final shop = MockShopData.GetShopData().first;


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
            icon: Icons.arrow_back,
            onPressed: () {
              _showMessage('its printed!');
            }
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
              onPressed: () => _showMessage('Sửa thông tin của Shop'),
              icon: Icons.edit)
        ],
      ),
      body:
      SingleChildScrollView(
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
                          backgroundImage: AssetImage(shop.shopLogo),
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
                Text(shop.shopName,
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
                                  text: '${shop.rating}/5.00',
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
                                text: formatCount(shop.followersCount),
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
                    text: shop.shopDescription ?? '',
                    labelIcons: Icons.description,
                ),

                const SizedBox (height: 20),

                Divider(),

                const SizedBox (height: 20),

                Infofield(
                  label: 'Địa chỉ của shop',
                  text: '${shop.addressLine}, ${shop.ward}, ${shop.district}, ${shop.provinceOrCity}',
                  labelIcons: Icons.markunread_mailbox,
                ),
                const SizedBox (height: 20),

                Divider(),

                const SizedBox (height: 20),

                Infofield(
                  label: 'Email',
                  text: shop.email,
                  labelIcons: Icons.mail,
                ),
                const SizedBox (height: 20),

                Divider(),


                const SizedBox (height: 20),

                Infofield(
                  label: 'Số điện thoại',
                  text: shop.phone,
                  labelIcons: Icons.phone_enabled,
                ),
              ],
            ),
          ),
        ),
      );
  }
}
