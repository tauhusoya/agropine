import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationCacheService {
  static const String _cacheKeyLatitude = 'location_cache_latitude';
  static const String _cacheKeyLongitude = 'location_cache_longitude';
  static const String _cacheKeyTimestamp = 'location_cache_timestamp';
  static const Duration _cacheExpiration = Duration(hours: 24);

  // Get cached location or fetch new one if expired
  static Future<Position?> getLocationWithCache() async {
    try {
      // Try to get cached location
      final cachedLocation = await _getCachedLocation();
      
      if (cachedLocation != null) {
        final timestamp = await _getCacheTimestamp();
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // If cache is still valid (within 24 hours), return it
        if (timestamp != null && 
            now - timestamp < _cacheExpiration.inMilliseconds) {
          return cachedLocation;
        }
      }

      // If cache is expired or doesn't exist, fetch new location
      final newLocation = await _fetchFreshLocation();
      if (newLocation != null) {
        await _cacheLocation(newLocation);
      }
      return newLocation;
    } catch (e) {
      // If error, try to return cached location anyway
      return await _getCachedLocation();
    }
  }

  // Force refresh location (on-demand)
  static Future<Position?> refreshLocationOnDemand() async {
    try {
      final newLocation = await _fetchFreshLocation();
      if (newLocation != null) {
        await _cacheLocation(newLocation);
      }
      return newLocation;
    } catch (e) {
      return null;
    }
  }

  // Fetch fresh location from device
  static Future<Position?> _fetchFreshLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  // Cache location to local storage
  static Future<void> _cacheLocation(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_cacheKeyLatitude, position.latitude);
      await prefs.setDouble(_cacheKeyLongitude, position.longitude);
      await prefs.setInt(
        _cacheKeyTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Silently fail - caching is not critical
    }
  }

  // Get cached location
  static Future<Position?> _getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble(_cacheKeyLatitude);
      final longitude = prefs.getDouble(_cacheKeyLongitude);

      if (latitude != null && longitude != null) {
        return Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          heading: 0,
          accuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
          altitude: 0,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get cache timestamp
  static Future<int?> _getCacheTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_cacheKeyTimestamp);
    } catch (e) {
      return null;
    }
  }

  // Clear cache manually
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyLatitude);
      await prefs.remove(_cacheKeyLongitude);
      await prefs.remove(_cacheKeyTimestamp);
    } catch (e) {
      // Silently fail
    }
  }

  // Check if location is cached and valid
  static Future<bool> isCacheValid() async {
    try {
      final timestamp = await _getCacheTimestamp();
      if (timestamp == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      return now - timestamp < _cacheExpiration.inMilliseconds;
    } catch (e) {
      return false;
    }
  }
}
