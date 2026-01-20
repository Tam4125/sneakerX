import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/modules/seller_info/screens/edit_seller_infor.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/shop_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class SellerInfo extends StatefulWidget {
  const SellerInfo({Key? key}) : super(key: key);

  @override
  State<SellerInfo> createState() => _SellerInfoState();
}

class _SellerInfoState extends State<SellerInfo> {
  final ShopService _shopService = ShopService();

  bool _isLoading = true;

  // --- Display Data ---
  String _shopName = "";
  String _shopDescription = "No description provided.";
  String _shopLogoUrl = "";
  DateTime? _createdAt;

  // Stats
  double _shopRating = 0.0;
  int _followerCount = 0;
  int _productCount = 0;
  int _orderCount = 0;

  // Contact Info
  String _shopEmail = "";
  String _shopPhone = "No phone set";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser?.user;

    try {
      // 1. Fetch Shop Details (Returns ApiResponse<ShopDetailResponse>)
      final shopRes = await _shopService.getCurrentUserShop();
      // 2. Fetch User Addresses

      if (mounted) {
        setState(() {
          // --- Parse Shop Data ---
          if (shopRes.success && shopRes.data != null) {
            final data = shopRes.data!;

            // Basic Info
            _shopName = data.shop.shopName;
            _shopDescription = data.shop.shopDescription ?? "No description provided.";
            _shopLogoUrl = data.shop.shopLogo;
            _createdAt = data.shop.createdAt;
            _shopRating = data.shop.rating;

            // Computed Stats from Lists
            _followerCount = data.followers.length; // Or use data.shop.followersCount
            _productCount = data.products.length;
            _orderCount = data.shopOrders.length;
          }
          if (user != null) {
            _shopEmail = user.email;
            _shopPhone = user.phone;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black, size: 20),
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
                  (r) => false
          ),
        ),
        title: Text(
          'Shop Profile',
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditShopInfoScreen())
              );
              if (result == true) {
                setState(() => _isLoading = true);
                _initializeData();
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- 1. HEADER PROFILE ---
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[200]!, width: 2),
                image: _shopLogoUrl.isNotEmpty
                    ? DecorationImage(image: NetworkImage(_shopLogoUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: _shopLogoUrl.isEmpty ? const Icon(Icons.store, size: 40, color: Colors.grey) : null,
            ),
            const SizedBox(height: 16),
            Text(
              _shopName.isNotEmpty ? _shopName : "Unnamed Shop",
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _createdAt != null
                  ? "Joined ${DateFormat('MMMM yyyy').format(_createdAt!)}"
                  : "Joined Recently",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // --- 2. STATS DASHBOARD ---
            // Using a Grid-like layout for better data presentation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                      _shopRating.toStringAsFixed(1),
                      "Rating",
                      Icons.star_rounded,
                      Colors.amber
                  ),
                  _buildDivider(),
                  _buildStatItem(
                      _formatCount(_followerCount),
                      "Followers",
                      Icons.people_alt_rounded,
                      Colors.blue
                  ),
                  _buildDivider(),
                  _buildStatItem(
                      _productCount.toString(),
                      "Products",
                      Icons.inventory_2_rounded,
                      Colors.purple
                  ),
                  _buildDivider(),
                  _buildStatItem(
                      _orderCount.toString(),
                      "Orders",
                      Icons.shopping_bag_rounded,
                      Colors.green
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 3. ABOUT SECTION ---
            Align(
                alignment: Alignment.centerLeft,
                child: Text("About Shop", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold))
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _shopDescription,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600], height: 1.5),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 20),

            // --- 4. CONTACT INFO ---
            Align(
                alignment: Alignment.centerLeft,
                child: Text("Contact Information", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold))
            ),
            // const SizedBox(height: 16),
            // _buildContactItem(Icons.location_on_outlined, "Address", _shopAddress),
            const SizedBox(height: 16),
            _buildContactItem(Icons.email_outlined, "Email", _shopEmail),
            const SizedBox(height: 16),
            _buildContactItem(Icons.phone_outlined, "Phone", _shopPhone),

            // Bottom spacing
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: Colors.grey[300]);
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!)
          ),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(content, style: GoogleFonts.inter(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    return "${(count / 1000).toStringAsFixed(1)}k";
  }
}