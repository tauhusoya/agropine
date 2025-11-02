import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/authentication_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agropine',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthenticationScreen(),
    );
  }
}
