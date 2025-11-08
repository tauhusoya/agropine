import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

/// Firestore collections schema and service
/// 
/// Collections to create:
/// 1. users - User profiles (buyers, farmers, traders)
/// 2. farmers - Farmer/vendor profiles with location
/// 3. products - Products offered by farmers
/// 4. categories - Product categories
/// 5. ratings - User ratings and reviews
/// 6. orders - (Future) Purchase orders

class FirestoreCollectionsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String usersCollection = 'users';
  static const String farmersCollection = 'farmers';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String ratingsCollection = 'ratings';
  static const String ordersCollection = 'orders';

  // ======================== USERS COLLECTION ========================
  // Schema:
  // {
  //   uid: string (document ID)
  //   email: string
  //   displayName: string
  //   photoURL: string (optional)
  //   userType: string ('buyer', 'farmer', 'trader')
  //   phone: string
  //   address: string
  //   createdAt: timestamp
  //   updatedAt: timestamp
  // }

  static Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required String userType, // 'buyer', 'farmer', 'trader'
    String? phone,
    String? address,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).set({
        'email': email,
        'displayName': displayName,
        'userType': userType,
        'phone': phone ?? '',
        'address': address ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // ======================== FARMERS COLLECTION ========================
  // Schema:
  // {
  //   farmerId: string (document ID)
  //   userId: string (reference to users collection)
  //   farmName: string
  //   location: geopoint
  //   address: string
  //   description: string
  //   phone: string
  //   verified: boolean
  //   rating: number
  //   ratingCount: number
  //   products: array (reference IDs)
  //   createdAt: timestamp
  //   updatedAt: timestamp
  // }

  static Future<String> createFarmerProfile({
    required String userId,
    required String farmName,
    required double latitude,
    required double longitude,
    required String address,
    String? description,
    String? phone,
  }) async {
    try {
      final docRef = await _firestore.collection(farmersCollection).add({
        'userId': userId,
        'farmName': farmName,
        'location': GeoPoint(latitude, longitude),
        'address': address,
        'description': description ?? '',
        'phone': phone ?? '',
        'verified': false,
        'rating': 0.0,
        'ratingCount': 0,
        'products': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create farmer profile: $e');
    }
  }

  // Get nearby farmers (within radius)
  static Future<List<DocumentSnapshot>> getNearbyFarmers({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) async {
    try {
      // Note: Firestore doesn't natively support radius queries
      // This is a simple approach - in production, use algolia/elasticsearch
      final snapshot = await _firestore.collection(farmersCollection).get();
      
      final List<DocumentSnapshot> nearby = [];
      for (var doc in snapshot.docs) {
        final geopoint = doc['location'] as GeoPoint;
        final distance = _calculateDistance(
          latitude,
          longitude,
          geopoint.latitude,
          geopoint.longitude,
        );
        if (distance <= radiusInKm) {
          nearby.add(doc);
        }
      }
      
      // Sort by distance
      nearby.sort((a, b) {
        final distA = _calculateDistance(
          latitude,
          longitude,
          (a['location'] as GeoPoint).latitude,
          (a['location'] as GeoPoint).longitude,
        );
        final distB = _calculateDistance(
          latitude,
          longitude,
          (b['location'] as GeoPoint).latitude,
          (b['location'] as GeoPoint).longitude,
        );
        return distA.compareTo(distB);
      });
      
      return nearby;
    } catch (e) {
      throw Exception('Failed to get nearby farmers: $e');
    }
  }

  // ======================== PRODUCTS COLLECTION ========================
  // Schema:
  // {
  //   productId: string (document ID)
  //   farmerId: string (reference)
  //   categoryId: string (reference)
  //   name: string
  //   description: string
  //   price: number
  //   unit: string ('kg', 'bunch', 'piece', etc)
  //   quantity: number
  //   image: string (URL)
  //   rating: number
  //   createdAt: timestamp
  // }

  static Future<String> createProduct({
    required String farmerId,
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String unit,
    required int quantity,
    String? imageUrl,
  }) async {
    try {
      final docRef = await _firestore.collection(productsCollection).add({
        'farmerId': farmerId,
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'unit': unit,
        'quantity': quantity,
        'image': imageUrl ?? '',
        'rating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  // ======================== CATEGORIES COLLECTION ========================
  // Schema:
  // {
  //   categoryId: string (document ID)
  //   name: string
  //   icon: string (emoji or URL)
  //   description: string
  //   createdAt: timestamp
  // }

  static Future<void> createDefaultCategories() async {
    try {
      final categories = [
        {'name': 'Medication', 'icon': '💊', 'description': 'Agricultural medicines and pesticides'},
        {'name': 'Jam', 'icon': '🍓', 'description': 'Homemade jams and preserves'},
        {'name': 'Fruits', 'icon': '🍎', 'description': 'Fresh fruits and produce'},
        {'name': 'Seeds', 'icon': '🌱', 'description': 'Seeds and saplings'},
        {'name': 'Health', 'icon': '❤️', 'description': 'Health and wellness products'},
      ];

      final batch = _firestore.batch();
      for (final category in categories) {
        final docRef = _firestore.collection(categoriesCollection).doc();
        batch.set(docRef, {
          'name': category['name'],
          'icon': category['icon'],
          'description': category['description'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create categories: $e');
    }
  }

  // Get all categories
  static Future<List<DocumentSnapshot>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection(categoriesCollection)
          .orderBy('createdAt')
          .get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // ======================== RATINGS COLLECTION ========================
  // Schema:
  // {
  //   ratingId: string (document ID)
  //   userId: string (reference)
  //   farmerId: string (reference)
  //   rating: number (1-5)
  //   comment: string
  //   createdAt: timestamp
  // }

  static Future<void> createRating({
    required String userId,
    required String farmerId,
    required double rating,
    String? comment,
  }) async {
    try {
      await _firestore.collection(ratingsCollection).add({
        'userId': userId,
        'farmerId': farmerId,
        'rating': rating,
        'comment': comment ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update farmer's average rating
      await _updateFarmerRating(farmerId);
    } catch (e) {
      throw Exception('Failed to create rating: $e');
    }
  }

  static Future<void> _updateFarmerRating(String farmerId) async {
    try {
      final ratingsSnapshot = await _firestore
          .collection(ratingsCollection)
          .where('farmerId', isEqualTo: farmerId)
          .get();

      if (ratingsSnapshot.docs.isEmpty) return;

      double totalRating = 0;
      for (var doc in ratingsSnapshot.docs) {
        totalRating += doc['rating'] as double;
      }

      final averageRating = totalRating / ratingsSnapshot.docs.length;

      await _firestore.collection(farmersCollection).doc(farmerId).update({
        'rating': averageRating,
        'ratingCount': ratingsSnapshot.docs.length,
      });
    } catch (e) {
      throw Exception('Failed to update farmer rating: $e');
    }
  }

  // Helper function to calculate distance between two coordinates (Haversine)
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final sinHalfDLat = math.sin(dLat / 2);
    final sinHalfDLon = math.sin(dLon / 2);
    
    final a = sinHalfDLat * sinHalfDLat +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            sinHalfDLon *
            sinHalfDLon;

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * 3.14159265359 / 180;
  }
}

// Math helper
class MathHelper {
  static double sin(double x) => math.sin(x);
  static double cos(double x) => math.cos(x);
  static double atan2(double y, double x) => math.atan2(y, x);
  static double sqrt(double x) => math.sqrt(x);
}
