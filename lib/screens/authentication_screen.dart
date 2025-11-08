import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/carousel_landing.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'vendor_email_page.dart';
import 'vendor_waiting_page.dart';
import 'vendor_details_page.dart';
import 'main_tab_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  int _currentScreenIndex = 0;
  late FirebaseAuthService _firebaseAuthService;
  String? _verifiedVendorEmail; // Store email after verification

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

  void _switchToVendorEmail() {
    setState(() {
      _currentScreenIndex = 4;
    });
  }

  void _switchToVendorWaiting(String email) {
    setState(() {
      _verifiedVendorEmail = email;
      _currentScreenIndex = 5;
    });
  }

  void _switchToVendorDetails(String email) {
    setState(() {
      _verifiedVendorEmail = email;
      _currentScreenIndex = 6;
    });
  }

  void _onVendorRegistrationComplete() {
    // This callback is called when vendor registration completes
    // We force a rebuild of the widget tree, which will trigger the StreamBuilder
    debugPrint('Vendor registration complete - triggering setState');
    setState(() {
      // Force rebuild - the StreamBuilder will now see the user is logged in and flag is false
    });
  }

  void _switchToLanding() {
    // Clear vendor registration mode when going back to landing
    _firebaseAuthService.setVendorRegistrationMode(false);
    _firebaseAuthService.clearTemporaryVendorEmail();
    
    setState(() {
      _currentScreenIndex = 0;
      _verifiedVendorEmail = null;
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
        // Debug logging
        debugPrint('AuthenticationScreen StreamBuilder rebuild');
        debugPrint('User: ${snapshot.data?.email}');
        debugPrint('isInVendorRegistration: ${_firebaseAuthService.isInVendorRegistration}');
        
        // If user is authenticated AND we're not in vendor registration flow, show main tab screen
        if (snapshot.hasData && snapshot.data != null && !_firebaseAuthService.isInVendorRegistration) {
          debugPrint('Showing MainTabScreen for user: ${snapshot.data?.email}');
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
        return CarouselLanding(
          key: const ValueKey(0),
          onContinueAsVendor: _switchToVendorEmail,
          onContinueAsGuest: _handleGuestLogin,
        );
      case 1:
        return LoginPage(
          key: const ValueKey(1),
          onSwitchToRegister: _switchToRegister,
          onSwitchToVendor: _switchToVendorEmail,
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
      case 4:
        return VendorEmailPage(
          key: const ValueKey(4),
          onBackToLanding: _switchToLanding,
          onSignIn: _switchToLogin,
          onEmailSent: _switchToVendorWaiting,
          firebaseAuthService: _firebaseAuthService,
        );
      case 5:
        return VendorWaitingPage(
          key: const ValueKey(5),
          email: _verifiedVendorEmail!,
          onBackToLanding: _switchToLanding,
          onEmailVerified: _switchToVendorDetails,
          firebaseAuthService: _firebaseAuthService,
        );
      case 6:
        return VendorDetailsPage(
          key: const ValueKey(6),
          verifiedEmail: _verifiedVendorEmail!,
          onBackToLanding: _switchToLanding,
          firebaseAuthService: _firebaseAuthService,
          onRegistrationComplete: _onVendorRegistrationComplete,
        );
      default:
        return CarouselLanding(
          key: const ValueKey(0),
          onContinueAsVendor: _switchToVendorEmail,
          onContinueAsGuest: _handleGuestLogin,
        );
    }
  }
}
