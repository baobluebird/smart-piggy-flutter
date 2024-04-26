import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:smart_piggy/pages/login.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('myBox');

  runApp(const MaterialApp(
      title: 'Smart Piggy App',
      debugShowCheckedModeBanner: false,
      home: Login()));
}