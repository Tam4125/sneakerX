import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/modules/profile/view/empty_profile_view.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/order_status_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (authProvider.isGuest) {
      return const EmptyProfileView();
    } else {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Light grey background
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Header & Order Status (Combined for overlap effect)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100), // Space for the floating card
                    child: ProfileHeader(user: user!.user),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: OrderStatusBar(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Wallet & Loyalty Section
              _buildSection([
                _buildMenuItem(Icons.account_balance_wallet_outlined, "My Wallet", "Connect Now", isHighlight: true),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(Icons.card_giftcard, "Voucher Warehouse", "3 Available"),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(Icons.diamond_outlined, "Loyalty Member", "Silver Member"),
              ]),

              const SizedBox(height: 12),

              // 3. Activity Section
              _buildSection([
                _buildMenuItem(Icons.favorite_border, "My Wishlist", "12 Items"),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(Icons.history, "Recently Viewed", ""),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(Icons.star_outline, "My Reviews", ""),
              ]),

              const SizedBox(height: 12),

              // 4. Support Section
              _buildSection([
                _buildMenuItem(Icons.settings_outlined, "Account Settings", ""),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(Icons.help_outline, "Help Centre", ""),
              ]),

              const SizedBox(height: 30),

              // // Logout (Optional)
              // TextButton(
              //   onPressed: () => authProvider.logout(),
              //   child: Text("Sign Out", style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600)),
              // ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {bool isHighlight = false}) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: isHighlight ? Colors.orange : Colors.grey[600], size: 24),
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle.isNotEmpty)
            Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: isHighlight ? Colors.orange : Colors.grey)),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[300], size: 14),
        ],
      ),
      onTap: () {},
    );
  }
}