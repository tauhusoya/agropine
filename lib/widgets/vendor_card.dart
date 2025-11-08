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
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile section with picture, name, and verification badge
                _buildProfileSection(context),
                const SizedBox(height: 12),

                // Location and phone side by side
                if ((_businessLocation != null && _businessLocation!.isNotEmpty) ||
                    (_phoneNumber != null && _phoneNumber!.isNotEmpty))
                  _buildLocationAndPhoneRow(),
                if ((_businessLocation != null && _businessLocation!.isNotEmpty) ||
                    (_phoneNumber != null && _phoneNumber!.isNotEmpty))
                  const SizedBox(height: 10),

                // Harvest month (farmers only)
                if (showHarvestMonth && _harvestMonth != null)
                  _buildHarvestMonthRow(),
                if (showHarvestMonth && _harvestMonth != null)
                  const SizedBox(height: 10),

                // Products pills at bottom
                if (_products.isNotEmpty) _buildProductsPills(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build profile section with picture, name, type, and verification badge
  Widget _buildProfileSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile picture
        _buildProfilePicture(),
        const SizedBox(width: 12),

        // Business name, person name, description, and verification badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business name (top)
              Text(
                vendor['businessName'] as String? ?? vendor['name'] as String? ?? 'Unknown',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Person name (below business name)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      vendor['name'] as String? ?? 'Unknown',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isVerified) const SizedBox(width: 6),
                  if (_isVerified) _buildVerificationBadge(),
                ],
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                vendor['description'] as String? ?? '',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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

  /// Build location and phone side by side
  Widget _buildLocationAndPhoneRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location
        if (_businessLocation != null && _businessLocation!.isNotEmpty)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '$_businessLocation • $distanceText',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        if (_businessLocation != null &&
            _businessLocation!.isNotEmpty &&
            _phoneNumber != null &&
            _phoneNumber!.isNotEmpty)
          const SizedBox(width: 12),
        // Phone
        if (_phoneNumber != null && _phoneNumber!.isNotEmpty)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.phone,
                  size: 16,
                  color: AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _phoneNumber ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Build harvest month row (for farmers only)
  Widget _buildHarvestMonthRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.calendar_today,
          size: 16,
          color: AppTheme.primaryGold,
        ),
        const SizedBox(width: 6),
        Text(
          'Harvest: $_harvestMonth',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.primaryGold,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build products pills
  Widget _buildProductsPills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: _products
              .take(3)
              .map((product) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      product,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
        if (_products.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '+${_products.length - 3} more product${_products.length - 3 > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
