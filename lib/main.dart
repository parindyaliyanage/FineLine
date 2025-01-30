import 'package:flutter/material.dart';
import 'screens/SignUpScreen.dart';
import 'screens/SignInScreen.dart';
import 'screens/homePage.dart';
import 'screens/Hamburger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Up Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Scaffold(
        body: SignUpScreen(),
      ),
    );
  }
}