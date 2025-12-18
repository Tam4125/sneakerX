import 'package:flutter/material.dart';


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
      home: ProductDetailView(productId: 3,),
    );
  }
}