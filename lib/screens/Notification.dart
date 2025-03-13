import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white), // ✅ Make title text white
        ),
        backgroundColor: const Color(0xFF1a4a7c),
        iconTheme: const IconThemeData(color: Colors.white), // ✅ Make back button white
      ),
      body: const Center(
        child: Text("This is the Notification Page"),
      ),
    );
  }
}
