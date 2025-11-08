import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import 'landing_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'main_tab_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  int _currentScreenIndex = 0;
  late FirebaseAuthService _firebaseAuthService;

  @override
  void initState() {
    super.initState();
    _firebaseAuthService = FirebaseAuthService();
  }

  void _switchToRegister() {
    setState(() {
      _currentScreenIndex = 2;
    });
  }

  void _switchToLogin() {
    setState(() {
      _currentScreenIndex = 1;
    });
  }

  void _switchToForgotPassword() {
    setState(() {
      _currentScreenIndex = 3;
    });
  }

  void _switchToLanding() {
    setState(() {
      _currentScreenIndex = 0;
    });
  }

  void _logout() {
    _firebaseAuthService.signOut().then((_) {
      setState(() {
        _currentScreenIndex = 0;
      });
    });
  }

  Future<void> _handleGuestLogin() async {
    try {
      debugPrint('Starting guest login...');
      await _firebaseAuthService.signInAnonymously();
      debugPrint('Guest login successful!');
      // Navigation will be handled by StreamBuilder when auth state changes
    } catch (e) {
      debugPrint('Guest login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in as guest: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _firebaseAuthService.authStateChanges,
      builder: (context, snapshot) {
        // If user is authenticated, show main tab screen with dashboard and profile
        if (snapshot.hasData && snapshot.data != null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: MainTabScreen(
                key: const ValueKey(4),
                onLogout: _logout,
                isFirstTimeSignup: _firebaseAuthService.isFirstTimeSignup,
              ),
            ),
          );
        }

        // If user is not authenticated, show auth screens
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildCurrentScreen(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreenIndex) {
      case 0:
        return LandingPage(
          key: const ValueKey(0),
          onContinueAsVendor: _switchToLogin,
          onContinueAsGuest: _handleGuestLogin,
        );
      case 1:
        return LoginPage(
          key: const ValueKey(1),
          onSwitchToRegister: _switchToRegister,
          onForgotPassword: _switchToForgotPassword,
          onBackToLanding: _switchToLanding,
        );
      case 2:
        return RegisterPage(
          key: const ValueKey(2),
          onSwitchToLogin: _switchToLogin,
          onBackToLanding: _switchToLanding,
        );
      case 3:
        return ForgotPasswordPage(
          key: const ValueKey(3),
          onBackToLogin: _switchToLogin,
        );
      default:
        return LandingPage(
          key: const ValueKey(0),
          onContinueAsVendor: _switchToLogin,
          onContinueAsGuest: _handleGuestLogin,
        );
    }
  }
}
