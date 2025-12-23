import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/modules/cart/view/cart_view.dart';
import 'package:sneakerx/src/modules/seller/product/screens/my_product_list.dart';
import 'package:sneakerx/src/modules/seller/product/screens/product_addition.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';
import 'src/modules/product_detail/view/product_detail_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
      ],
      child: const NeakerXApp(),
    )
  );
}

class NeakerXApp extends StatelessWidget {
  const NeakerXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeakerX',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: MainScreen(),
    );
  }
}