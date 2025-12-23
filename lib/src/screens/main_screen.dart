import 'package:flutter/material.dart';
import 'package:sneakerx/src/modules/cart/view/cart_view.dart';
import 'package:sneakerx/src/modules/homepage/screens/home_screen.dart';
import 'package:sneakerx/src/modules/profile/view/profile_view.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _mainScreenState();
}

class _mainScreenState extends State<MainScreen> {

  late int _selectedIndex;

  // 1. Define the list of screens for each tab
  final List<Widget> _pages = [
    const HomeScreen(),
    const Center(child: Text("Search Screen")), // Index 1: Placeholder
    const Center(child: Text("Notifications")), // Index 2: Placeholder
    const CartView(),   // Index 3: Placeholder
    const ProfileView(),// Index 4: Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add_outlined),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ]
      ),
    );
  }
}