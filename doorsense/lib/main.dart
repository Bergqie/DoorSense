import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/welcome_page.dart';
import 'package:flutter/material.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DoorSense',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.grey,
      secondaryHeaderColor: Colors.purple,
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: const WelcomeScreen(),

  );
}