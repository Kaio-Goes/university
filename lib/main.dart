import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:university/pages/landingPage/dashboard/dashboard_page.dart';
import 'package:university/pages/secretary/class_create_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:university/pages/secretary/dashboard/dashboard_secretary_page.dart';
import 'package:university/pages/secretary/login/login_secretary_page.dart';
import 'package:university/pages/secretary/student_create_page.dart';
import 'package:university/pages/secretary/teacher_create_page.dart';

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
      databaseURL: "https://anna-nery-default-rtdb.firebaseio.com/",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    if (role == 'admin') {
      return const ClassCreatePage();
    } else {
      return const DashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return MaterialApp(
            title: 'Anna Nery',
            locale: const Locale('pt', 'BR'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('pt', 'BR'),
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: snapshot.data ?? const DashboardPage(),
          );
        }
      },
    );
  }
}