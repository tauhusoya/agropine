import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../services/firebase_analytics_service.dart';
import '../services/analytics_service.dart';
import '../widgets/vendor_card.dart';

class SellersListPage extends StatefulWidget {
  const SellersListPage({super.key});

  @override
  State<SellersListPage> createState() => _SellersListPageState();
}

class _SellersListPageState extends State<SellersListPage> {
  late TextEditingController _searchController;
  String? _selectedCategory;
  String? _selectedType; // 'Farmer' or 'Trader'
  String _sortBy = 'distance'; // 'distance', 'rating', 'name'
  Position? _userLocation;
  bool _locationLoading = false;
  List<Map<String, dynamic>> _filteredSellers = [];
  List<Map<String, dynamic>> _allSellers = [];

  // Categories with emoji as placeholder images (same as dashboard)
  final List<Map<String, String>> _categories = [
    {'name': 'Medication', 'icon': '💊'},
    {'name': 'Jam', 'icon': '🍓'},
    {'name': 'Fruits', 'icon': '🍎'},
    {'name': 'Seeds', 'icon': '🌱'},
    {'name': 'Health', 'icon': '❤️'},
  ];

  // Sample sellers/traders data (same as dashboard)
  final List<Map<String, dynamic>> _sellersAndTraders = [
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
      'products': ['Jam', 'Health', 'Medication'],
      'rating': 4.7,
      'reviews': 142,
      'phoneNumber': '012-456-7890',
      'description': 'Homemade traditional jam made from the finest fruits.',
      'location': 'Subang',
    },
    {
      'id': '5',
      'name': 'Sunny Citrus Farm',
      'businessName': 'Sunny Citrus',
      'type': 'Farmer',
      'latitude': 3.1370,
      'longitude': 101.6850,
      'products': ['Fruits', 'Juice'],
      'rating': 4.6,
      'reviews': 98,
      'phoneNumber': '018-567-8901',
      'description': 'Fresh citrus fruits delivered to your doorstep daily.',
      'location': 'Selamat',
      'harvestMonth': 'May',
    },
    {
      'id': '6',
      'name': 'Wellness Herbs Trader',
      'businessName': 'Wellness Herbs',
      'type': 'Trader',
      'latitude': 3.1405,
      'longitude': 101.6875,
      'products': ['Health', 'Medication'],
      'rating': 4.9,
      'reviews': 175,
      'phoneNumber': '017-678-9012',
      'description': 'Herbal remedies and wellness products for natural healing.',
      'location': 'Shah Alam',
    },
    {
      'id': '7',
      'name': 'Pineapple Paradise',
      'businessName': 'Pineapple Paradise',
      'type': 'Farmer',
      'latitude': 3.1385,
      'longitude': 101.6860,
      'products': ['Fruits', 'Seeds', 'Jam'],
      'rating': 5.0,
      'reviews': 289,
      'phoneNumber': '016-789-0123',
      'description': 'Award-winning pineapples and pineapple products. Freshly harvested daily.',
      'location': 'Serdang',
      'harvestMonth': 'April',
    },
    {
      'id': '8',
      'name': 'Eco Garden Supplier',
      'businessName': 'Eco Garden',
      'type': 'Trader',
      'latitude': 3.1420,
      'longitude': 101.6890,
      'products': ['Seeds', 'Equipment', 'Vegetables'],
      'rating': 4.4,
      'reviews': 67,
      'phoneNumber': '012-890-1234',
      'description': 'Organic gardening supplies and equipment for your garden.',
      'location': 'Cyberjaya',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _allSellers = _sellersAndTraders;
    _applyFilters();
    _loadUserLocation();
    AnalyticsService.logPageView(pageName: 'Sellers List');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    try {
      setState(() {
        _locationLoading = true;
      });

      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _userLocation = position;
          _locationLoading = false;
          _applyFilters(); // Reapply filters to sort by distance
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationLoading = false;
        });
      }
      debugPrint('Error loading location: $e');
    }
  }

  List<Map<String, dynamic>> _getSortedAndFilteredSellers() {
    var filtered = _allSellers.where((seller) {
      // Search filter
      final matchesSearch = _searchController.text.isEmpty ||
          seller['name']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

      // Type filter
      final matchesType = _selectedType == null || seller['type'] == _selectedType;

      // Category filter
      final matchesCategory = _selectedCategory == null ||
          (seller['products'] as List<String>).contains(_selectedCategory);

      return matchesSearch && matchesType && matchesCategory;
    }).toList();

    // Add distance to each seller
    if (_userLocation != null) {
      for (var seller in filtered) {
        final distance = LocationService.calculateDistance(
          _userLocation!.latitude,
          _userLocation!.longitude,
          seller['latitude'] as double,
          seller['longitude'] as double,
        );
        seller['distance'] = distance;
      }
    }

    // Apply sorting
    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) {
          final ratingB = b['rating'] as num;
          final ratingA = a['rating'] as num;
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'name':
        filtered.sort((a, b) {
          return (a['name'] as String).compareTo(b['name'] as String);
        });
        break;
      case 'distance':
      default:
        filtered.sort((a, b) {
          final distA = a['distance'] as double? ?? double.infinity;
          final distB = b['distance'] as double? ?? double.infinity;
          return distA.compareTo(distB);
        });
    }

    return filtered;
  }

  void _applyFilters() {
    setState(() {
      _filteredSellers = _getSortedAndFilteredSellers();
    });
    // Log search for analytics
    FirebaseAnalyticsService.logFarmerSearch(
      category: _selectedCategory,
      resultCount: _filteredSellers.length,
    );
  }

  String _getFilterValue() {
    switch (_sortBy) {
      case 'rating':
        return 'sort_rating';
      case 'name':
        return 'sort_name';
      case 'distance':
      default:
        return 'sort_distance';
    }
  }

  List<DropdownMenuItem<String>> _buildFilterMenuItems() {
    return [
      const DropdownMenuItem<String>(
        value: 'sort_distance',
        child: Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text('Nearby'),
        ),
      ),
      const DropdownMenuItem<String>(
        value: 'sort_rating',
        child: Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text('Popular'),
        ),
      ),
      const DropdownMenuItem<String>(
        value: 'sort_name',
        child: Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text('Name (A-Z)'),
        ),
      ),
    ];
  }

  void _applyFilterFromDropdown(String? value) {
    if (value == null) return;

    setState(() {
      if (value.startsWith('sort_')) {
        _sortBy = value.replaceFirst('sort_', '');
      }
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSellers = _getSortedAndFilteredSellers();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sellers'),
        backgroundColor: AppTheme.primaryGold,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppTheme.textLight),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryGold),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
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
                                _applyFilters();
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
                  const SizedBox(height: 12),
                  // Filter Dropdown (Full Width)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: DropdownButton<String>(
                      value: _getFilterValue(),
                      hint: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text('Filter'),
                      ),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _buildFilterMenuItems(),
                      onChanged: (value) {
                        _applyFilterFromDropdown(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Results Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredSellers.length} Result${filteredSellers.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textLight,
                            ),
                      ),
                      if (_locationLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sellers List
                  if (filteredSellers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No sellers found',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        ...filteredSellers.asMap().entries.map((entry) {
                          final seller = entry.value;
                          final distanceText = seller['distance'] != null
                              ? LocationService.formatDistance(seller['distance'] as double)
                              : 'N/A';

                          return VendorCard(
                            vendor: seller,
                            distanceText: distanceText,
                            showHarvestMonth: false,
                            onTap: () {
                              _showSellerDetails(seller);
                            },
                          );
                        }),
                        const SizedBox(height: 80),
                      ],
                    ),
                ],
            ),
          ),
        ),
      );
  }

  void _showSellerDetails(Map<String, dynamic> seller) {
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
                seller['businessName'] as String? ?? seller['name'] as String? ?? 'Unknown',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                seller['name'] as String? ?? 'Unknown',
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
                      seller['type'] as String? ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if ((seller['ssmId'] as String?)?.isNotEmpty ?? false)
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
                seller['description'] as String? ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              // Location & Distance
              if (seller['location'] != null && (seller['location'] as String).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppTheme.primaryGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            seller['location'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                    if (seller['distance'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Text(
                              LocationService.formatDistance(seller['distance'] as double),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              // Phone Number
              if (seller['phoneNumber'] != null && (seller['phoneNumber'] as String).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: AppTheme.primaryGold),
                        const SizedBox(width: 8),
                        Text(
                          seller['phoneNumber'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
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
                children: (seller['products'] as List<String>?)?.take(4).map((product) => Chip(
                      label: Text(product),
                      backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ))
                    .toList() ?? [],
              ),
              if (((seller['products'] as List<String>?)?.length ?? 0) > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${(seller['products'] as List<String>).length - 4} more products',
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
                        content: Text('Contact ${seller['name']} feature coming soon!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'Contact Seller',
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
}
