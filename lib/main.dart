import 'package:flutter/material.dart';
import 'package:sneakerx/src/modules/profile/view/profile_view.dart';


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
      // Đây là nơi bảo Flutter chạy màn hình mới của chúng ta
      home: ProfileView(),
    );
  }
}