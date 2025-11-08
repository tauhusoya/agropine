import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/authentication_screen.dart';
import 'services/analytics_service.dart';
import 'services/asset_management_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Crash Reporting and Analytics
  await AnalyticsService.initCrashReporting();
  
  // Initialize Asset Optimization
  await AssetManagementService.initializeAssetOptimization();
  
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
      home: AuthenticationScreen(),
    );
  }
}
