import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snkrxx/screens/my_product_list.dart';
import 'package:snkrxx/screens/seller_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ShopDashboardScreen(),
    ),
    GoRoute(
      path: '/productlist',
      builder: (context, state) => const ShopProductList(),
    ),
  ],
);