import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:university/pages/landingPage/dashboard/dashboard_page.dart';
import 'package:university/pages/secretary/login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: String.fromEnvironment('API_KEY'),
      appId: String.fromEnvironment('APP_ID'),
      messagingSenderId: String.fromEnvironment('MESSAGING_SENDER_ID'),
      projectId: String.fromEnvironment('PROJECT_ID'),
      authDomain: String.fromEnvironment('AUTH_DOMAIN'),
      storageBucket: String.fromEnvironment('STORAGE_BUCKET'),
      databaseURL: String.fromEnvironment('DATABASE_URL'),
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anna Nery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
