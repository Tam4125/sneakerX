import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/modules/cart/view/cart_view.dart';
import 'package:sneakerx/src/modules/search/screen/search_screen.dart';
import 'package:sneakerx/src/modules/seller_dashboard/screens/seller_ui.dart';
import 'package:sneakerx/src/modules/seller_dashboard/widgets/dashboard_card.dart';
import 'package:sneakerx/src/modules/seller_signup/screens/seller_signup.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';
import 'src/modules/product_detail/view/product_detail_view.dart';
import 'package:sneakerx/src/modules/cart/view/empty_cart_view.dart';
import 'package:sneakerx/src/modules/profile/view/empty_profile_view.dart';
import 'package:sneakerx/src/modules/profile/view/settings_view.dart';
import 'package:sneakerx/src/modules/profile/view/edit_address_view.dart';
import 'package:sneakerx/src/modules/profile/view/order_history_view.dart';
void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // FIX: Initialize Stripe with your Publishable Key
  // Go to Stripe Dashboard -> Developers -> API Keys -> Publishable Key
  Stripe.publishableKey = "pk_test_51ShBFGCc0iar3PLkGSvtsgu7olXysQJIMTcxc76IWQfZhFMg02QOlTuGz95tfDHb011p5p5sESoKxS2EC53PtEgc00cFCGDrHj";

  // Optional: Apply settings
  await Stripe.instance.applySettings();

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