import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  int _currentScreenIndex = 0; // 0: Login, 1: Register, 2: Forgot Password

  void _switchToRegister() {
    setState(() {
      _currentScreenIndex = 1;
    });
  }

  void _switchToLogin() {
    setState(() {
      _currentScreenIndex = 0;
    });
  }

  void _switchToForgotPassword() {
    setState(() {
      _currentScreenIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
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
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreenIndex) {
      case 0:
        return LoginPage(
          key: const ValueKey(0),
          onSwitchToRegister: _switchToRegister,
          onForgotPassword: _switchToForgotPassword,
        );
      case 1:
        return RegisterPage(
          key: const ValueKey(1),
          onSwitchToLogin: _switchToLogin,
        );
      case 2:
        return ForgotPasswordPage(
          key: const ValueKey(2),
          onBackToLogin: _switchToLogin,
        );
      default:
        return LoginPage(
          key: const ValueKey(0),
          onSwitchToRegister: _switchToRegister,
          onForgotPassword: _switchToForgotPassword,
        );
    }
  }
}
