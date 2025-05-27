
import 'package:fire_chat/linking_service.dart';
import 'package:fire_chat/page_handler.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LinkService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chaty Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PageHandler.page, // Initial screen
    );
  }
}
