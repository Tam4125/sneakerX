import 'package:flutter/material.dart';
import 'package:untitled3/src/modules/homepage/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopee Clone',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
      ),
      home: const HomeScreen(),
    );
  }
}