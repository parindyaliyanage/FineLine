import 'package:fineline/repositiries/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'screens/SignUpScreen.dart';
import 'screens/SignInScreen.dart';
import 'screens/homePage.dart';
import 'screens/Hamburger.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runApp(const MyApp());


// ...

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,).then(
      (FirebaseApp value) => Get.put(AuthenticationRepository())
  );
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
        body: HomePage(username: "Parindya"),
      ),
    );
  }
}