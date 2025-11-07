import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/welcome_modal.dart';
import '../services/firebase_auth_service.dart';
import '../services/location_service.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onLogout;
  final bool isFirstTimeSignup;

  const DashboardPage({
    super.key,
    required this.onLogout,
    this.isFirstTimeSignup = false,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _welcomeShown = false;
  late FirebaseAuthService _authService;
  PageController? _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  Position? _userLocation;
  bool _locationLoading = false;
  List<Map<String, dynamic>>? _sortedFarmersCache;
  Position? _lastLocationForCache;
  String? _selectedCategory;
  bool _locationLoadingStarted = false;

  // Sample announcements/images
  final List<String> _announcements = [
    'Welcome to AgroPine! Explore our features.',
    'Check out the latest updates and news.',
    'Join our community for more information.',
    'Follow us for daily tips and tricks.',
  ];

  // Categories with emoji as placeholder images
  final List<Map<String, String>> _categories = [
    {'name': 'Medication', 'icon': '💊'},
    {'name': 'Jam', 'icon': '🍓'},
    {'name': 'Fruits', 'icon': '🍎'},
    {'name': 'Seeds', 'icon': '🌱'},
    {'name': 'Health', 'icon': '❤️'},
  ];

  // Sample farmers/traders data
  final List<Map<String, dynamic>> _farmersAndTraders = [
    {
      'id': '1',
      'name': 'Green Valley Farm',
      'type': 'Farmer',
      'latitude': 3.1390,
      'longitude': 101.6869,
      'products': ['Fruits', 'Seeds', 'Vegetables'],
      'rating': 4.8,
      'reviews': 156,
    },
    {
      'id': '2',
      'name': 'Fresh Harvest Trader',
      'type': 'Trader',
      'latitude': 3.1425,
      'longitude': 101.6905,
      'products': ['Medication', 'Health'],
      'rating': 4.5,
      'reviews': 89,
    },
    {
      'id': '3',
      'name': 'Organic Seeds Co',
      'type': 'Farmer',
      'latitude': 3.1350,
      'longitude': 101.6820,
      'products': ['Seeds', 'Fruits'],
      'rating': 4.9,
      'reviews': 203,
    },
    {
      'id': '4',
      'name': 'Heritage Jam House',
      'type': 'Trader',
      'latitude': 3.1410,
      'longitude': 101.6880,
      'products': ['Jam', 'Health'],
      'rating': 4.6,
      'reviews': 112,
    },
  ];

  @override
  void initState() {
    super.initState();
    _authService = FirebaseAuthService();
    _pageController = PageController();
    
    // Auto-slide carousel every 5 seconds
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && _pageController?.hasClients == true) {
        int nextPage = (_currentPage + 1) % _announcements.length;
        _pageController?.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    if (widget.isFirstTimeSignup) {
      // Show welcome immediately for first-time signup
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeModalForNewUser();
        // Reset the flag after showing
        _authService.resetFirstTimeSignupFlag();
        // Load location after showing welcome
        _loadUserLocation();
      });
    } else {
      // Check Firestore for subsequent logins
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeModalIfFirstTime();
        // Load location after modal check
        _loadUserLocation();
      });
    }
  }

  Future<void> _showWelcomeModalForNewUser() async {
    if (_welcomeShown) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _welcomeShown = true;
      final firstName = user.displayName?.split(' ').first ?? 'User';

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WelcomeModal(
            userName: firstName,
            onClose: () async {
              Navigator.pop(context);
              // Mark welcome as seen
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .update({'hasSeenWelcome': true});
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error showing welcome modal: $e');
    }
  }

  Future<void> _showWelcomeModalIfFirstTime() async {
    if (_welcomeShown) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Add a small delay to ensure Firestore data is synced
      await Future.delayed(const Duration(milliseconds: 500));

      // Retry logic in case data isn't available immediately
      DocumentSnapshot<Map<String, dynamic>>? userDoc;
      for (int i = 0; i < 3; i++) {
        userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          break;
        }
        
        if (i < 2) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      if (userDoc == null || !userDoc.exists || !mounted) return;

      final data = userDoc.data();
      final hasSeenWelcome = data?['hasSeenWelcome'] ?? false;

      if (!hasSeenWelcome && !_welcomeShown) {
        _welcomeShown = true;
        final firstName = data?['firstName'] ?? 'User';

        // Show welcome modal
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => WelcomeModal(
              userName: firstName,
              onClose: () async {
                Navigator.pop(context);
                // Mark welcome as seen
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({'hasSeenWelcome': true});
              },
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error showing welcome modal: $e');
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserLocation() async {
    // Prevent multiple simultaneous location loads
    if (_locationLoadingStarted) return;
    
    setState(() {
      _locationLoadingStarted = true;
      _locationLoading = true;
    });

    try {
      final position = await LocationService().getCurrentLocation();
      if (mounted) {
        setState(() {
          _userLocation = position;
          _locationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationLoading = false;
        });
      }
      debugPrint('Error loading location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _locationLoadingStarted = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getSortedFarmersAndTraders() {
    // Use cache if location hasn't changed
    if (_lastLocationForCache == _userLocation && _sortedFarmersCache != null) {
      return _sortedFarmersCache!;
    }

    if (_userLocation == null) {
      _sortedFarmersCache = _farmersAndTraders;
      return _farmersAndTraders;
    }

    try {
      // Calculate distance for each farmer/trader
      final farmersWithDistance = <Map<String, dynamic>>[];
      
      for (final farmer in _farmersAndTraders) {
        try {
          final lat = farmer['latitude'] as double?;
          final lng = farmer['longitude'] as double?;
          
          if (lat == null || lng == null) continue;
          
          final distance = LocationService.calculateDistance(
            _userLocation!.latitude,
            _userLocation!.longitude,
            lat,
            lng,
          );
          
          farmersWithDistance.add({
            ...farmer,
            'distance': distance,
          });
        } catch (e) {
          // Skip farmer if distance calculation fails
          debugPrint('Error calculating distance for farmer: $e');
          continue;
        }
      }

      // Sort by distance (closest first)
      farmersWithDistance.sort((a, b) {
        final distA = a['distance'] as double;
        final distB = b['distance'] as double;
        return distA.compareTo(distB);
      });

      _sortedFarmersCache = farmersWithDistance;
      _lastLocationForCache = _userLocation;
      return farmersWithDistance;
    } catch (e) {
      debugPrint('Error sorting farmers: $e');
      return _farmersAndTraders;
    }
  }

  List<Map<String, dynamic>> _getFilteredFarmers() {
    final sorted = _getSortedFarmersAndTraders();
    
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      return sorted;
    }

    return sorted.where((farmer) {
      final products = farmer['products'] as List<String>?;
      return products?.contains(_selectedCategory) ?? false;
    }).toList();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppTheme.primaryGold,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmation,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header with User Name
              Text(
                'Welcome, ${FirebaseAuth.instance.currentUser?.displayName ?? 'Guest'}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              // Carousel with auto-slide
              SizedBox(
                height: 150,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _announcements.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _announcements[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Dot indicators
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _announcements.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? AppTheme.primaryGold
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Categories Section
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Horizontal scrollable category cards
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category['name'];
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedCategory == category['name']) {
                              // Deselect if already selected
                              _selectedCategory = null;
                            } else {
                              // Select this category
                              _selectedCategory = category['name'];
                            }
                          });
                        },
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? AppTheme.primaryGold.withValues(alpha: 0.1)
                              : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                ? AppTheme.primaryGold 
                                : AppTheme.borderColor,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                category['icon']!,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category['name']!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              // Farmers & Traders Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby Farmers & Traders',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_locationLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_locationLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_userLocation == null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_off, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enable Location',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Grant permission to see nearby farmers and traders',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadUserLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              child: const Text(
                                'Enable Now',
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Builder(
                  builder: (context) {
                    final filteredFarmers = _getFilteredFarmers();
                    
                    if (filteredFarmers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedCategory != null
                                    ? 'No farmers found for $_selectedCategory'
                                    : 'No farmers nearby',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredFarmers.length,
                      itemBuilder: (context, index) {
                        final farmer = filteredFarmers[index];
                        final distance = farmer['distance'] as double;
                        final distanceText =
                            LocationService.formatDistance(distance);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          farmer['name'] as String,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryGold
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                farmer['type'] as String,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.primaryGold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                distanceText,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.green,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star,
                                                size: 16, color: Colors.orange),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                farmer['rating'].toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${farmer['reviews']} reviews',
                                          style: const TextStyle(fontSize: 10),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: (farmer['products'] as List<String>)
                                    .map((product) => Chip(
                                      label: Text(product),
                                      backgroundColor: AppTheme.primaryGold
                                          .withValues(alpha: 0.1),
                                      labelStyle: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.primaryGold,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                    ))
                                    .toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
