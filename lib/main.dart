import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:university/pages/landingPage/dashboard/dashboard_page.dart';
import 'package:university/pages/secretary/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBfSLtX70brczNL-G8KYvAJ62iw_fyc3CM",
      appId: "1:630386930561:web:2529c7f0b58008dcccee80",
      messagingSenderId: "630386930561",
      projectId: "anna-nery",
      authDomain: "anna-nery.firebaseapp.com",
      storageBucket: "anna-nery.appspot.com",
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
