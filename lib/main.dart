import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_storage/app_binding.dart';
import 'package:learn_storage/persentation/barang_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Learn Storage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialBinding: AppBinding(),
      home: const BarangPage(),
    );
  }
}
