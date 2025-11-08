import 'package:flutter/material.dart';
import '../widgets/floating_bottom_navbar.dart';
import '../services/notification_service.dart';
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
  late NotificationService _notificationService;
  int _notificationCount = 0;
  int _messageCount = 0;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _startListeningToNotifications();
  }

  void _startListeningToNotifications() {
    // Listen to unread notifications
    _notificationService.getUnreadNotificationsStream().listen((count) {
      setState(() {
        _notificationCount = count;
      });
    });

    // Listen to unread messages
    _notificationService.getUnreadMessagesStream().listen((count) {
      setState(() {
        _messageCount = count;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Page content
          _buildPageContent(),
          
          // Floating bottom navbar with notification badges
          FloatingBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Mark notifications as read when profile tab is tapped
              if (index == 3) {
                _notificationService.markAllNotificationsAsRead();
              }
              // Mark messages as read when sellers tab is tapped
              if (index == 2) {
                _notificationService.markAllMessagesAsRead();
              }
            },
            notificationCount: _notificationCount,
            messageCount: _messageCount,
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
