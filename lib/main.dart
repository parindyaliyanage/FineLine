import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:fineline/repositiries/authentication_repository.dart';
import 'package:fineline/screens/SignInScreen.dart';
import 'package:fineline/screens/homePage.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize AuthenticationRepository
  Get.put(AuthenticationRepository()); // Add this line

  runApp(MyApp());
}

// Add this temporary function (remove after use)
Future<void> _forceCreateUsersCollection() async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc('test_doc')
        .set({'test': true});
    debugPrint('Debug: Successfully created users collection!');
  } catch (e) {
    debugPrint('Debug Error creating collection: $e');
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Your App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignInScreen(), // Directly navigate to SignInScreen
    );
  }
}