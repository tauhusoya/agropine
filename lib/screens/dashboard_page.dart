import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/welcome_modal.dart';
import '../widgets/vendor_card.dart';
import '../services/firebase_auth_service.dart';
import '../services/location_service.dart';
import '../services/analytics_service.dart';

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
  late FirebaseAuthService _authService;
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
      'businessName': 'Green Valley',
      'type': 'Farmer',
      'latitude': 3.1390,
      'longitude': 101.6869,
      'products': ['Fruits', 'Seeds', 'Vegetables'],
      'rating': 4.8,
      'reviews': 156,
      'phoneNumber': '016-123-4567',
      'description': 'Fresh organic fruits and vegetables from our farm. We practice sustainable farming methods.',
      'location': 'Kuala Lumpur',
      'harvestMonth': 'March',
    },
    {
      'id': '2',
      'name': 'Fresh Harvest Trader',
      'businessName': 'Fresh Harvest',
      'type': 'Trader',
      'latitude': 3.1425,
      'longitude': 101.6905,
      'products': ['Medication', 'Health'],
      'rating': 4.5,
      'reviews': 89,
      'phoneNumber': '017-234-5678',
      'description': 'Quality health and wellness products for you and your family.',
      'location': 'Petaling Jaya',
    },
    {
      'id': '3',
      'name': 'Organic Seeds Co',
      'businessName': 'Organic Seeds',
      'type': 'Farmer',
      'latitude': 3.1350,
      'longitude': 101.6820,
      'products': ['Seeds', 'Fruits'],
      'rating': 4.9,
      'reviews': 203,
      'phoneNumber': '016-345-6789',
      'description': 'Premium organic seeds for all types of crops. Certified and tested.',
      'location': 'Shah Alam',
      'harvestMonth': 'June',
    },
    {
      'id': '4',
      'name': 'Heritage Jam House',
      'businessName': 'Heritage Jam',
      'type': 'Trader',
      'latitude': 3.1410,
      'longitude': 101.6880,
      'products': ['Jam', 'Health'],
      'rating': 4.6,
      'reviews': 112,
      'phoneNumber': '012-456-7890',
      'description': 'Homemade traditional jam made from the finest fruits.',
      'location': 'Subang',
    },
  ];

  @override
  void initState() {
    super.initState();
    _authService = FirebaseAuthService();
    
    // Log dashboard page view
    AnalyticsService.logPageView(pageName: 'Dashboard');
    
    // Always check Firestore for welcome status, regardless of isFirstTimeSignup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeModalIfFirstTime();
      // Load location after modal check
      _loadUserLocation();
    });
    
    // Reset the first-time signup flag if this was a first-time signup
    if (widget.isFirstTimeSignup) {
      _authService.resetFirstTimeSignupFlag();
    }
  }

  Future<void> _showWelcomeModalIfFirstTime() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('No current user, skipping welcome check');
        return;
      }

      debugPrint('Checking Firestore for hasSeenWelcome...');

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

      if (userDoc == null || !userDoc.exists || !mounted) {
        debugPrint('User doc not found in Firestore');
        return;
      }

      final data = userDoc.data();
      final hasSeenWelcome = data?['hasSeenWelcome'] ?? false;
      debugPrint('hasSeenWelcome from Firestore: $hasSeenWelcome');

      if (!hasSeenWelcome) {
        debugPrint('Showing welcome modal');
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
                // Mark welcome as seen in Firestore
                debugPrint('Marking hasSeenWelcome as true');
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({'hasSeenWelcome': true});
                debugPrint('Welcome marked as seen');
              },
            ),
          );
        }
      } else {
        debugPrint('Welcome already seen, not showing modal');
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
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryYellow,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryYellow,
            ),
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

  void _showVendorDetails(Map<String, dynamic> vendor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Business Name & Person Name
              Text(
                vendor['businessName'] as String? ?? vendor['name'] as String? ?? 'Unknown',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                vendor['name'] as String? ?? 'Unknown',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
              ),
              const SizedBox(height: 12),
              // Type & Verification
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      vendor['type'] as String? ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if ((vendor['ssmId'] as String?)?.isNotEmpty ?? false)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 14, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                vendor['description'] as String? ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              // Location & Distance
              if (vendor['location'] != null && (vendor['location'] as String).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppTheme.primaryGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vendor['location'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 24),
                        Text(
                          vendor['distance'] != null ? LocationService.formatDistance(vendor['distance'] as double) : 'N/A',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              // Phone Number
              if (vendor['phoneNumber'] != null && (vendor['phoneNumber'] as String).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: AppTheme.primaryGold),
                        const SizedBox(width: 8),
                        Text(
                          vendor['phoneNumber'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              // Harvest Month (Farmers only)
              if ((vendor['type'] as String?) == 'Farmer' &&
                  vendor['harvestMonth'] != null &&
                  (vendor['harvestMonth'] as String).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryGold),
                        const SizedBox(width: 8),
                        Text(
                          'Harvest: ${vendor['harvestMonth']}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryGold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              const Divider(),
              const SizedBox(height: 12),
              // Products
              Text(
                'Products & Services',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (vendor['products'] as List<String>?)?.take(4).map((product) => Chip(
                      label: Text(product),
                      backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ))
                    .toList() ?? [],
              ),
              if (((vendor['products'] as List<String>?)?.length ?? 0) > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${(vendor['products'] as List<String>).length - 4} more products',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contact ${vendor['name']} feature coming soon!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'Contact Vendor',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 160.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    viewportFraction: 0.9,
                  ),
                  items: _announcements.map((announcement) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              announcement,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textDark,
                                    fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                  Expanded(
                    child: Text(
                      'Nearby Farmers & Traders',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

                        return VendorCard(
                          vendor: farmer,
                          distanceText: distanceText,
                          showHarvestMonth: false,
                          onTap: () {
                            _showVendorDetails(farmer);
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
