import 'package:flutter/material.dart';
import 'package:gas_app/gaz_calculate.dart';
import 'package:get/get.dart';

void main() {
  runApp(const GasApp());
}

class GasApp extends StatelessWidget {
  const GasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: GazCalculate(),
    );
  }
}
