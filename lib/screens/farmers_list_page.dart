import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../services/firebase_analytics_service.dart';
import '../services/search_history_service.dart';
import '../services/analytics_service.dart';
import '../widgets/vendor_card.dart';

class FarmersListPage extends StatefulWidget {
  const FarmersListPage({super.key});

  @override
  State<FarmersListPage> createState() => _FarmersListPageState();
}

class _FarmersListPageState extends State<FarmersListPage> {
  late TextEditingController _searchController;
  String? _selectedCategory;
  String? _selectedType; // 'Farmer' or 'Trader'
  String _sortBy = 'distance'; // 'distance', 'rating', 'name'
  Position? _userLocation;
  bool _locationLoading = false;
  List<Map<String, dynamic>> _filteredFarmers = [];
  List<Map<String, dynamic>> _allFarmers = [];
  
  // Pagination variables
  static const int itemsPerPage = 20;
  int _currentPage = 1;
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  
  // Search history
  List<String> _searchHistory = [];
  bool _showSearchSuggestions = false;
  // Categories for farmers (Raw and Seed - upstream only, not processed into food yet)
  final List<Map<String, String>> _categories = [
    {'name': 'Raw', 'icon': '🥕'},
    {'name': 'Seed', 'icon': '🌱'},
  ];

  // Sample farmers/traders data (same as dashboard)
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
      'phoneNumber': '016-567-8901',
      'description': 'Fresh citrus fruits and natural juices from our orchard.',
      'location': 'Damansara',
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
      'description': 'Herbal remedies and wellness products for natural health.',
      'location': 'Ampang',
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
    _searchController.addListener(_onSearchChanged);
    _allFarmers = _farmersAndTraders;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _applyFilters();
    _loadUserLocation();
    _loadSearchHistory();
    
    // Log page view
    AnalyticsService.logPageView(pageName: 'Farmers List');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSearchHistory() async {
    final history = await SearchHistoryService.getSearchHistory();
    if (mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _showSearchSuggestions = _searchController.text.isNotEmpty;
    });
  }
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (_isLoadingMore || _currentPage * itemsPerPage >= _allFarmers.length) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    });
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

  List<Map<String, dynamic>> _getSortedAndFilteredFarmers() {
    var filtered = _allFarmers.where((farmer) {
      // Enhanced search filter - checks name, business name, location
      final searchText = _searchController.text.toLowerCase();
      final nameMatch = farmer['name'].toString().toLowerCase().contains(searchText);
      final businessNameMatch = (farmer['businessName'] as String?)?.toLowerCase().contains(searchText) ?? false;
      final locationMatch = (farmer['location'] as String?)?.toLowerCase().contains(searchText) ?? false;
      final matchesSearch = searchText.isEmpty || nameMatch || businessNameMatch || locationMatch;

      // Type filter
      final matchesType = _selectedType == null || farmer['type'] == _selectedType;

      // Category filter
      final matchesCategory = _selectedCategory == null ||
          (farmer['products'] as List<String>).contains(_selectedCategory);

      return matchesSearch && matchesType && matchesCategory;
    }).toList();

    // Add distance to each farmer and filter by 5km radius
    const double defaultRadiusKm = 5.0;
    if (_userLocation != null) {
      for (var farmer in filtered) {
        final distance = LocationService.calculateDistance(
          _userLocation!.latitude,
          _userLocation!.longitude,
          farmer['latitude'] as double,
          farmer['longitude'] as double,
        );
        farmer['distance'] = distance;
      }
      
      // Filter to only show vendors within 5km radius
      filtered = filtered.where((farmer) {
        final distance = farmer['distance'] as double? ?? double.infinity;
        return distance <= defaultRadiusKm;
      }).toList();
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
    // Reset pagination when filters change
    _currentPage = 1;
    _isLoadingMore = false;
    setState(() {
      _filteredFarmers = _getSortedAndFilteredFarmers();
    });
    // Log search for analytics
    if (_searchController.text.isNotEmpty) {
      AnalyticsService.logSearch(
        searchTerm: _searchController.text,
        resultCount: _filteredFarmers.length,
        category: _selectedCategory,
        location: _userLocation != null
            ? LocationService.formatDistance(0)
            : null, // Placeholder
      );
    }
    FirebaseAnalyticsService.logFarmerSearch(
      category: _selectedCategory,
      resultCount: _filteredFarmers.length,
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
    final filteredFarmers = _getSortedAndFilteredFarmers();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Farmers'),
        backgroundColor: AppTheme.primaryGold,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section (Scrollable)
          SingleChildScrollView(
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
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        SearchHistoryService.addSearchTerm(value);
                        _loadSearchHistory();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name, location...',
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
                  // Search history suggestions
                  if (_showSearchSuggestions && _searchHistory.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchHistory.length,
                        itemBuilder: (context, index) {
                          final term = _searchHistory[index];
                          return ListTile(
                            leading: const Icon(Icons.history, size: 18, color: AppTheme.textLight),
                            title: Text(term, style: const TextStyle(fontSize: 14)),
                            onTap: () {
                              _searchController.text = term;
                              _applyFilters();
                              _showSearchSuggestions = false;
                              FocusScope.of(context).unfocus();
                              SearchHistoryService.addSearchTerm(term);
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                SearchHistoryService.removeSearchTerm(term);
                                _loadSearchHistory();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Horizontal scrollable category cards (Raw & Seed - upstream only)
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
                        '${filteredFarmers.length} Result${filteredFarmers.length != 1 ? 's' : ''}',
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
                ],
              ),
            ),
          ),
          // Farmers List with Pagination
          Expanded(
            child: filteredFarmers.isEmpty
                ? Center(
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
                            'No farmers found',
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
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 100),
                    itemCount: (filteredFarmers.length ~/ itemsPerPage + 1) + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, pageIndex) {
                      // Show loading indicator on last page while loading
                      if (_isLoadingMore && pageIndex == (filteredFarmers.length ~/ itemsPerPage)) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryGold,
                              ),
                            ),
                          ),
                        );
                      }

                      // Build farmers for this page
                      final startIndex = pageIndex * itemsPerPage;
                      final endIndex = ((pageIndex + 1) * itemsPerPage).clamp(0, filteredFarmers.length);
                      
                      if (startIndex >= filteredFarmers.length) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: filteredFarmers
                            .sublist(startIndex, endIndex)
                            .map((farmer) {
                          final distanceText = farmer['distance'] != null
                              ? LocationService.formatDistance(farmer['distance'] as double)
                              : 'N/A';

                          return VendorCard(
                            vendor: farmer,
                            distanceText: distanceText,
                            showHarvestMonth: true,
                            onTap: () {
                              _showFarmerDetails(farmer);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFarmerDetails(Map<String, dynamic> farmer) {
    // Log vendor view
    final distance = farmer['distance'] as double? ?? 0.0;
    AnalyticsService.logVendorView(
      vendorId: farmer['id'] as String,
      vendorName: farmer['name'] as String,
      vendorType: farmer['type'] as String,
      distance: distance,
    );

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
              Text(
                farmer['name'] as String,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
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
                children: (farmer['products'] as List<String>)
                    .map((product) => Chip(
                          label: Text(product),
                          backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.1),
                          labelStyle: const TextStyle(
                            color: AppTheme.primaryGold,
                            fontWeight: FontWeight.w500,
                          ),
                        ))
                    .toList(),
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
                        content: Text('Contact ${farmer['name']} feature coming soon!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'View Profile',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
