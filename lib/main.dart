import 'package:flutter/material.dart';
import 'package:sneakerx/src/modules/auth_features/views/introduction_screen.dart';
import 'package:sneakerx/src/modules/auth_features/views/sign_in.dart';
import 'package:sneakerx/src/modules/auth_features/views/sign_up.dart';
import 'src/modules/product_detail/view/product_detail_view.dart';

void main() {
  runApp(const NeakerXApp());
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
      home: SignInScreen(),
    );
  }
}