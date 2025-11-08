import 'package:flutter/material.dart';
import '../widgets/floating_bottom_navbar.dart';
import 'dashboard_page.dart';
import 'farmers_list_page.dart';
import 'sellers_list_page.dart';
import 'profile_page.dart';

class MainTabScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final bool isFirstTimeSignup;

  const MainTabScreen({
    super.key,
    required this.onLogout,
    this.isFirstTimeSignup = false,
  });

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Page content
          _buildPageContent(),
          
          // Floating bottom navbar
          FloatingBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_currentIndex) {
      case 0:
        return DashboardPage(
          onLogout: widget.onLogout,
          isFirstTimeSignup: widget.isFirstTimeSignup,
        );
      case 1:
        return const FarmersListPage();
      case 2:
        return const SellersListPage();
      case 3:
        return SellerProfilePage(
          onOpenSettings: () {
            // Handle settings navigation if needed
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings coming soon')),
            );
          },
        );
      default:
        return DashboardPage(
          onLogout: widget.onLogout,
          isFirstTimeSignup: widget.isFirstTimeSignup,
        );
    }
  }
}
