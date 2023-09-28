import 'package:doorsense/pages/home_page.dart';
import 'package:doorsense/pages/manage_users.dart';

import 'pages/welcome_page.dart';
import 'package:flutter/material.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DoorSense',
    theme: ThemeData(
      primarySwatch: Colors.orange,
      secondaryHeaderColor: Colors.purple,
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: const WelcomeScreen(),

  );
}