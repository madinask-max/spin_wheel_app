// main.dart

import 'package:flutter/material.dart';
import 'screens/spin_wheel_page.dart';
import 'screens/mobile_number_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MobileNumberPage(),
    );
  }
}