import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fineline/screens/auth_controller.dart';
import 'package:fineline/screens/role-selection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:fineline/repositiries/driver_auth_repository.dart';
import 'package:fineline/repositiries/officer_auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize both repositories
  Get.lazyPut(() => DriverAuthRepository(), fenix: true);
  Get.lazyPut(() => OfficerAuthRepository());
  Get.put(AuthController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FineLine App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RoleSelectionScreen(),
      getPages: [
        GetPage(name: '/role-selection', page: () => RoleSelectionScreen()),
      ],
    );
  }
}