import 'package:flutter/material.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/home/home_page.dart';
import 'config/theme.dart';

// THIS MUST BE AT THE TOP LEVEL
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechHub Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
