import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/image_cache_helper.dart';

/// Enhanced vendor card widget for farmers and sellers list
/// Shows profile picture, name, location, harvest month, products, and verification badge
class VendorCard extends StatelessWidget {
  final Map<String, dynamic> vendor;
  final String distanceText;
  final bool showHarvestMonth;
  final VoidCallback onTap;

  const VendorCard({
    super.key,
    required this.vendor,
    required this.distanceText,
    this.showHarvestMonth = false,
    required this.onTap,
  });

  /// Check if vendor has SSM ID (verification)
  bool get _isVerified => (vendor['ssmId'] as String?)?.isNotEmpty ?? false;

  /// Get profile picture URL or avatar
  String? get _profileImageUrl => vendor['profileImage'] as String?;

  /// Get business location
  String? get _businessLocation => vendor['location'] as String?;

  /// Get harvest month (farmers only)
  String? get _harvestMonth => vendor['harvestMonth'] as String?;

  /// Get products list
  List<String> get _products =>
      (vendor['products'] as List<dynamic>?)?.cast<String>() ?? [];

  /// Get phone number
  String? get _phoneNumber => vendor['phoneNumber'] as String?;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: Profile Header (Picture + Info)
                _buildHeaderSection(context),
                const SizedBox(height: 14),

                // SECTION 2 & 3: Contact Info and Harvest (Responsive - Side by side on web, stacked on mobile)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    
                    if (isMobile) {
                      // Mobile: Stack vertically
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Contact info
                          if ((_businessLocation != null && _businessLocation!.isNotEmpty) ||
                              (_phoneNumber != null && _phoneNumber!.isNotEmpty))
                            _buildContactSection(),
                          // Harvest month
                          if ((vendor['type'] as String?) == 'Farmer' &&
                              _harvestMonth != null &&
                              _harvestMonth!.isNotEmpty)
                            const SizedBox(height: 12),
                          if ((vendor['type'] as String?) == 'Farmer' &&
                              _harvestMonth != null &&
                              _harvestMonth!.isNotEmpty)
                            _buildHarvestSection(),
                        ],
                      );
                    } else {
                      // Web/Tablet: Side by side
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Contact info (location + phone)
                            if ((_businessLocation != null && _businessLocation!.isNotEmpty) ||
                                (_phoneNumber != null && _phoneNumber!.isNotEmpty))
                              Expanded(
                                flex: 2,
                                child: _buildContactSection(),
                              ),
                            // Harvest month
                            if ((vendor['type'] as String?) == 'Farmer' &&
                                _harvestMonth != null &&
                                _harvestMonth!.isNotEmpty)
                              const SizedBox(width: 12),
                            if ((vendor['type'] as String?) == 'Farmer' &&
                                _harvestMonth != null &&
                                _harvestMonth!.isNotEmpty)
                              Expanded(
                                flex: 1,
                                child: _buildHarvestSection(),
                              ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                if (((_businessLocation != null && _businessLocation!.isNotEmpty) ||
                        (_phoneNumber != null && _phoneNumber!.isNotEmpty)) ||
                    ((vendor['type'] as String?) == 'Farmer' &&
                        _harvestMonth != null &&
                        _harvestMonth!.isNotEmpty))
                  const SizedBox(height: 12),

                // SECTION 4: Products
                if (_products.isNotEmpty) _buildProductsSection(),
              ],
            ),
          ),
        ),
    );
  }

  /// SECTION 1: Header with profile picture and vendor info
  Widget _buildHeaderSection(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture (fixed size)
            _buildProfilePicture(),
            const SizedBox(width: 12),

            // Vendor info (name, type, description)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Business name
                  Text(
                    vendor['businessName'] as String? ??
                        vendor['name'] as String? ??
                        'Unknown',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Person name + Type badge in one row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor['name'] as String? ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          vendor['type'] as String? ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    vendor['description'] as String? ?? '',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textLight,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        // Verification badge - Top right
        if (_isVerified)
          Positioned(
            top: 0,
            right: 0,
            child: _buildVerificationBadge(),
          ),
      ],
    );
  }

  /// SECTION 2: Contact info (Location + Distance + Phone)
  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Location row
          if (_businessLocation != null && _businessLocation!.isNotEmpty)
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppTheme.primaryGold,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _businessLocation!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        distanceText,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          // Phone row
          if (_phoneNumber != null && _phoneNumber!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: _businessLocation != null &&
                        _businessLocation!.isNotEmpty
                    ? 8
                    : 0,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone,
                    size: 14,
                    color: AppTheme.primaryGold,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _phoneNumber!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// SECTION 3: Harvest month (farmers only)
  Widget _buildHarvestSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AppTheme.primaryGold,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Harvest: $_harvestMonth',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// SECTION 4: Products/Categories
  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Products',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
            ),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _products
              .take(4)
              .map((product) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppTheme.primaryGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      product,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
        if (_products.length > 4)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '+${_products.length - 4} more product${_products.length - 4 > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 9,
                color: AppTheme.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  /// Build profile picture widget - circular image only, no background
  Widget _buildProfilePicture() {
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return ClipOval(
        child: SizedBox(
          width: 75,
          height: 75,
          child: ImageCacheHelper.getCachedThumbnail(
            imageUrl: _profileImageUrl!,
          ),
        ),
      );
    }
    
    // Fallback to icon in circle when no image
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: Center(
        child: Icon(
          Icons.account_circle,
          size: 50,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  /// Build verification badge
  Widget _buildVerificationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: 14,
            color: Colors.green,
          ),
          SizedBox(width: 2),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
