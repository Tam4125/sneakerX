import 'package:flutter/material.dart';
import 'package:snkrxx/widgets/bottom_nav_button.dart';
import 'package:snkrxx/widgets/dashboard_card.dart';
import 'package:snkrxx/widgets/icon_button_widget.dart';
import 'package:snkrxx/data/mock_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snkrxx/main.dart';
import 'package:go_router/go_router.dart';


class ShopDashboardScreen extends StatefulWidget {
  const ShopDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopDashboardScreen> {

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
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButtonWidget(
          icon: Icons.arrow_back,
          onPressed: () => _showMessage('Nothign happened'),
        ),
        title:
        Text(
          'Shop của tôi',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButtonWidget(
            icon: Icons.help_outline,
            onPressed: () => _showMessage('Help clicked'),
          ),
          IconButtonWidget(
            icon: Icons.mail_outline,
            onPressed: () => _showMessage('Mail clicked'),
          ),
          IconButtonWidget(
            icon: Icons.notifications_outlined,
            onPressed: () => _showMessage('Notifications clicked'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Shop Header
          Flex(
            direction: Axis.horizontal,
            children: [
            Expanded(
            child: Container(
            color: Color(0xff86f4b5),
            padding: const EdgeInsets.all(16),
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(MockShopData.shopImage),
                ),
                Text(
                  MockShopData.shopName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.6,
                  ),
                ),
                const Icon(Icons.arrow_outward),
              ],
            ),
            ),
          ),
        ],
      ),
          SizedBox(
            height: 20,
          ),
          // Dashboard Card
          Expanded(
            child: SingleChildScrollView(
              child: DashboardCard(
                onTap: () => _showMessage('Dashboard statistics clicked'),
                followers: MockShopData.followers,
                revenue: MockShopData.revenue,
                returnRate: MockShopData.returnRate,
                reviewCount: MockShopData.reviewCount,
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SizedBox(
        height: 180, // gives room for overlap
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Purple background bar
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xff593c66),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Floating buttons
            Positioned(
              top: -10, // controls overlap amount
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: BottomNavButton(
                          icon: Icons.inventory_2_outlined,
                          label: 'Sản phẩm của tôi',
                          onPressed:() =>  context.go('/productlist'),
                        ),
                      ),
                      Expanded(
                        child: BottomNavButton(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Tài chính',
                          onPressed: () {
                            _showMessage('Navigated to finance');
                          },
                        ),
                      ),
                      Expanded(
                        child: BottomNavButton(
                          icon: Icons.trending_up,
                          label: 'Hiệu quả bán hàng',
                          onPressed: () {
                            _showMessage('Navigated to performance');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}