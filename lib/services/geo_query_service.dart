import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

/// Service for geolocation queries and distance calculations
class GeoQueryService {
  static final GeoQueryService _instance = GeoQueryService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory GeoQueryService() {
    return _instance;
  }

  GeoQueryService._internal();

  /// Get current user location
  Future<GeoPoint?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 15),
      );

      return GeoPoint(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get nearby vendors within specified radius (in km)
  Future<List<QueryDocumentSnapshot>> getNearbyVendors({
    required GeoPoint userLocation,
    required double radiusKm,
    String collection = 'users',
  }) async {
    try {
      final docs = await _firestore.collection(collection).get();
      final nearby = <QueryDocumentSnapshot>[];

      for (var doc in docs.docs) {
        if (doc.data().containsKey('location') && doc['location'] != null) {
          final vendorLocation = doc['location'] as GeoPoint;
          final distance = calculateDistance(userLocation, vendorLocation);
          if (distance <= radiusKm) {
            nearby.add(doc);
          }
        }
      }

      return nearby;
    } catch (e) {
      print('Error getting nearby vendors: $e');
      return [];
    }
  }

  /// Search vendors by location with custom filters
  Future<List<QueryDocumentSnapshot>> searchByLocation({
    required GeoPoint userLocation,
    required double radiusKm,
    required String accountType, // 'farmer' or 'seller'
    String collection = 'users',
  }) async {
    try {
      final docs = await _firestore
          .collection(collection)
          .where('accountType', isEqualTo: accountType)
          .get();

      final nearby = <QueryDocumentSnapshot>[];

      for (var doc in docs.docs) {
        if (doc.data().containsKey('location') && doc['location'] != null) {
          final vendorLocation = doc['location'] as GeoPoint;
          final distance = calculateDistance(userLocation, vendorLocation);
          if (distance <= radiusKm) {
            nearby.add(doc);
          }
        }
      }

      return nearby;
    } catch (e) {
      print('Error searching by location: $e');
      return [];
    }
  }

  /// Calculate distance between two GeoPoints (returns distance in km)
  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadiusKm = 6371;

    double lat1Rad = _degreesToRadians(point1.latitude);
    double lat2Rad = _degreesToRadians(point2.latitude);
    double deltaLat = _degreesToRadians(point2.latitude - point1.latitude);
    double deltaLon = _degreesToRadians(point2.longitude - point1.longitude);

    double a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Sort vendors by distance from user
  List<QueryDocumentSnapshot> sortByDistance({
    required List<QueryDocumentSnapshot> vendors,
    required GeoPoint userLocation,
  }) {
    final vendorsWithDistance = vendors.map((doc) {
      final vendorLocation = doc['location'] as GeoPoint?;
      final distance = vendorLocation != null
          ? calculateDistance(userLocation, vendorLocation)
          : double.infinity;
      return {'doc': doc, 'distance': distance};
    }).toList();

    vendorsWithDistance.sort((a, b) =>
        (a['distance'] as double).compareTo(b['distance'] as double));

    return vendorsWithDistance.map((item) => item['doc'] as QueryDocumentSnapshot).toList();
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

