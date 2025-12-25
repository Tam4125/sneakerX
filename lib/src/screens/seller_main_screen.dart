import 'package:flutter/material.dart';
import 'package:sneakerx/src/modules/seller_dashboard/screens/seller_ui.dart';
import 'package:sneakerx/src/modules/seller_info/screens/seller_info.dart';
import 'package:sneakerx/src/modules/seller_order/screens/seller_orders.dart';
import 'package:sneakerx/src/modules/seller_product/screens/my_product_list.dart';

class SellerMainScreen extends StatefulWidget {
  const SellerMainScreen({super.key});

  @override
  State<SellerMainScreen> createState() => _MainSellerScreenState();
}

class _MainSellerScreenState extends State<SellerMainScreen> {

  int _selectedIndex = 0;

  // 1. Define the list of screens for each tab
  final List<Widget> _pages = [
    const SellerDashboardScreen(),
    const ShopProductList(), // Index 1: Placeholder
    const SellerOrders(),
    const SellerInfo(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // 2. The body switches based on the index
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // Using IndexedStack preserves the state of tabs
      ),
      // 3. The Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF67D696),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 10,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storage),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_alt),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Profile',
            ),
          ]
      ),
    );
  }
}