import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Singleton service class for all Firebase Firestore operations
/// Usage: DatabaseService.instance.functionName()
class DatabaseService {
  // Private constructor for singleton pattern
  DatabaseService._();

  // Singleton instance
  static final DatabaseService instance = DatabaseService._();

  // Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Firebase Storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  final String _usersCollection = 'users';
  final String _categoriesCollection = 'categories';
  final String _productsCollection = 'products';
  final String _cartCollection = 'cart';
  final String _ordersCollection = 'orders';
  final String _rewardsCollection = 'rewards';
  final String _couponsCollection = 'coupons';

  // COUPONS COLLECTION
  // ============================================================================

  Future<bool> addCoupon({
    required String code,
    required int discountPercent,
    required DateTime expiryDate,
  }) async {
    try {
      await _db.collection(_couponsCollection).doc(code.toUpperCase()).set({
        'code': code.toUpperCase(),
        'discountPercent': discountPercent,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding coupon: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllCoupons() async {
    try {
      final snapshot = await _db.collection(_couponsCollection).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteCoupon(String code) async {
    await _db.collection(_couponsCollection).doc(code).delete();
  }

  Future<Map<String, dynamic>?> validateCoupon(String code) async {
  final doc = await FirebaseFirestore.instance
      .collection('coupons')
      .doc(code)
      .get();

  if (!doc.exists) return null;

  final data = doc.data()!;

  // 🔒 Check if already used
  if (data['used'] == true) return null;

  // ⏰ Check expiry (if exists)
  if (data.containsKey('expiresAt')) {
    final expiry = (data['expiresAt'] as Timestamp).toDate();
    if (DateTime.now().isAfter(expiry)) return null;
  }

  return {
    'code': doc.id,
    'discountPercent': data['discountPercent'],
  };
}


//WALLET
Future<double> getWalletBalance(String uid) async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  if (!doc.exists) return 0.0;

  return (doc.data()?['walletBalance'] ?? 0).toDouble();
}

Future<void> updateWalletBalance({
  required String uid,
  required double newBalance,
}) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .update({
    'walletBalance': newBalance,
  });
}

Future<void> addToWallet({
  required String uid,
  required double amount,
}) async {
  final ref =
      FirebaseFirestore.instance.collection('users').doc(uid);

  await FirebaseFirestore.instance.runTransaction((tx) async {
    final snapshot = await tx.get(ref);
    final current = (snapshot.data()?['walletBalance'] ?? 0).toDouble();
    tx.update(ref, {
      'walletBalance': current + amount,
    });
  });
}


  // ============================================================================
  // FIREBASE STORAGE FUNCTIONS (For uploading product images)
  // ============================================================================

  /// Upload image to Firebase Storage and return download URL
  /// Example: String? imageUrl = await DatabaseService.instance.uploadProductImage(imageFile, 'product_123.jpg');
  Future<String?> uploadProductImage(File imageFile, String fileName) async {
    try {
      // Create reference to Firebase Storage location
      final storageRef = _storage.ref().child('products/$fileName');

      // Upload file
      final uploadTask = await storageRef.putFile(imageFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Delete image from Firebase Storage
  /// Example: await DatabaseService.instance.deleteProductImage('product_123.jpg');
  Future<bool> deleteProductImage(String imageUrl) async {
    try {
      final storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  Future<void> createRewardCoupon(String userId) async {
    final couponRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .doc(); // auto ID

    await couponRef.set({
      'code': 'REWARD500',
      'discountType': 'flat',
      'discountValue': 500,
      'used': false,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 30)),
      ),
    });
  }

  Future<void> markCouponUsed(String userId, String couponId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .doc(couponId)
        .update({'used': true});
  }

  // ============================================================================
  // USERS COLLECTION
  // ============================================================================

  /// Create a new user document
  /// Example: await DatabaseService.instance.createUser('uid123', 'John Doe', 'john@example.com', 'hashedPassword', '123 Main St');
  Future<bool> createUser({
    required String uid,
    required String name,
    required String email,
    required String password,
    String? address,
  }) async {
    try {
      await _db.collection(_usersCollection).doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'password': password,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  /// Get user data by UID
  /// Example: Map<String, dynamic>? user = await DatabaseService.instance.getUser('uid123');
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _db.collection(_usersCollection).doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Update user information
  /// Example: await DatabaseService.instance.updateUser('uid123', name: 'Jane Doe', address: '456 Oak Ave');
  Future<bool> updateUser({
    required String uid,
    String? name,
    String? email,
    String? password,
    String? address,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (password != null) updates['password'] = password;
      if (address != null) updates['address'] = address;

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await _db.collection(_usersCollection).doc(uid).update(updates);
      }
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // ============================================================================
  // CATEGORIES COLLECTION
  // ============================================================================

  /// Add a new category
  /// Example: await DatabaseService.instance.addCategory('Men', parentCategory: null);
  Future<String?> addCategory({
    required String title,
    String? parentCategory,
  }) async {
    try {
      final docRef = await _db.collection(_categoriesCollection).add({
        'title': title,
        'parentCategory': parentCategory,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding category: $e');
      return null;
    }
  }

  /// Get all categories
  /// Example: List<Map<String, dynamic>> categories = await DatabaseService.instance.getCategories();
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final snapshot = await _db.collection(_categoriesCollection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  /// Get categories by parent (for nested categories)
  /// Example: List<Map<String, dynamic>> menCategories = await DatabaseService.instance.getCategoriesByParent('Men');
  Future<List<Map<String, dynamic>>> getCategoriesByParent(
    String? parentCategory,
  ) async {
    try {
      final snapshot = await _db
          .collection(_categoriesCollection)
          .where('parentCategory', isEqualTo: parentCategory)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting categories by parent: $e');
      return [];
    }
  }

  // ============================================================================
  // PRODUCTS COLLECTION - FIXED WITH GENDER FIELD
  // ============================================================================

  /// Add a new product - FIXED: Now includes gender field
  /// Example: await DatabaseService.instance.addProduct('Blue Jeans', 3999, 'cat_123', gender: 'Men', imageUrl: 'https://image.url');
  Future<String?> addProduct({
    required String name,
    required int price,
    required String categoryId,
    String? gender, // ✅ ADDED GENDER FIELD
    String? imageUrl,
    String? description,
  }) async {
    try {
      final docRef = await _db.collection(_productsCollection).add({
        'name': name,
        'price': price,
        'categoryId': categoryId,
        'gender': gender, // ✅ ADDED GENDER FIELD
        'imageUrl': imageUrl,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  /// Update existing product - FIXED: Now includes gender field
  /// Example: await DatabaseService.instance.updateProduct('prod_123', name: 'Updated Name', price: 4999, gender: 'Women');
  Future<bool> updateProduct({
    required String productId,
    String? name,
    int? price,
    String? categoryId,
    String? gender, // ✅ ADDED GENDER FIELD
    String? imageUrl,
    String? description,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (price != null) updates['price'] = price;
      if (categoryId != null) updates['categoryId'] = categoryId;
      if (gender != null) updates['gender'] = gender; // ✅ ADDED GENDER FIELD
      if (imageUrl != null) updates['imageUrl'] = imageUrl;
      if (description != null) updates['description'] = description;

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await _db
            .collection(_productsCollection)
            .doc(productId)
            .update(updates);
      }
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  /// Delete product
  /// Example: await DatabaseService.instance.deleteProduct('prod_123');
  Future<bool> deleteProduct(String productId) async {
    try {
      await _db.collection(_productsCollection).doc(productId).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  /// Get products by category
  /// Example: List<Map<String, dynamic>> products = await DatabaseService.instance.getProductsByCategory('cat_123');
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String categoryId,
  ) async {
    try {
      final snapshot = await _db
          .collection(_productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }

  /// Get all products
  /// Example: List<Map<String, dynamic>> allProducts = await DatabaseService.instance.getAllProducts();
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final snapshot = await _db.collection(_productsCollection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  /// Get single product by ID
  /// Example: Map<String, dynamic>? product = await DatabaseService.instance.getProduct('prod_123');
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      final doc = await _db
          .collection(_productsCollection)
          .doc(productId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // ============================================================================
  // CART COLLECTION
  // ============================================================================

  /// Add item to cart (or update quantity if already exists)
  /// Example: await DatabaseService.instance.addToCart('user123', 'prod_456', 2);
  Future<bool> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final cartId = '${userId}_$productId';
      await _db.collection(_cartCollection).doc(cartId).set({
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  /// Get all cart items for a user
  /// Example: List<Map<String, dynamic>> cartItems = await DatabaseService.instance.getCartItems('user123');
  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    try {
      final snapshot = await _db
          .collection(_cartCollection)
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

  /// Get cart items with real-time updates (Stream)
  /// Example: StreamBuilder(stream: DatabaseService.instance.getCartItemsStream('user123'), ...)
  Stream<List<Map<String, dynamic>>> getCartItemsStream(String userId) {
    return _db
        .collection(_cartCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  /// Update cart item quantity
  /// Example: await DatabaseService.instance.updateCartQuantity('user123', 'prod_456', 5);
  Future<bool> updateCartQuantity({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final cartId = '${userId}_$productId';
      if (quantity <= 0) {
        return await removeFromCart(userId: userId, productId: productId);
      }
      await _db.collection(_cartCollection).doc(cartId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating cart quantity: $e');
      return false;
    }
  }

  /// Remove item from cart
  /// Example: await DatabaseService.instance.removeFromCart(userId: 'user123', productId: 'prod_456');
  Future<bool> removeFromCart({
    required String userId,
    required String productId,
  }) async {
    try {
      final cartId = '${userId}_$productId';
      await _db.collection(_cartCollection).doc(cartId).delete();
      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  /// Clear entire cart for a user
  /// Example: await DatabaseService.instance.clearCart('user123');
  Future<bool> clearCart(String userId) async {
    try {
      final snapshot = await _db
          .collection(_cartCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // ============================================================================
  // ORDERS COLLECTION
  // ============================================================================

  /// Place a new order
  /// Example: await DatabaseService.instance.placeOrder('user123', [{'productId': 'prod_1', 'quantity': 2}], 7998);
  Future<String?> placeOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required int totalAmount,
  }) async {
    try {
      final docRef = await _db.collection(_ordersCollection).add({
        'userId': userId,
        'items': items,
        'totalAmount': totalAmount,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      return docRef.id;
    } catch (e) {
      print('Error placing order: $e');
      return null;
    }
  }

  /// Get all orders for a user
  /// Example: List<Map<String, dynamic>> orders = await DatabaseService.instance.getUserOrders('user123');
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final snapshot = await _db
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['orderId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting user orders: $e');
      return [];
    }
  }

  /// Get single order by ID
  /// Example: Map<String, dynamic>? order = await DatabaseService.instance.getOrder('order_123');
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      final doc = await _db.collection(_ordersCollection).doc(orderId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['orderId'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  /// Update order status
  /// Example: await DatabaseService.instance.updateOrderStatus('order_123', 'delivered');
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _db.collection(_ordersCollection).doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // ============================================================================
  // REWARDS COLLECTION
  // ============================================================================

  /// Get reward points for a user
  /// Example: int points = await DatabaseService.instance.getRewardPoints('user123');
  Future<int> getRewardPoints(String userId) async {
    try {
      final doc = await _db.collection(_rewardsCollection).doc(userId).get();
      if (doc.exists) {
        return doc.data()?['points'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting reward points: $e');
      return 0;
    }
  }

  /// Update reward points (add or subtract)
  /// Example: await DatabaseService.instance.updateRewardPoints('user123', 100); // Add 100 points
  /// Example: await DatabaseService.instance.updateRewardPoints('user123', -50); // Subtract 50 points
  Future<bool> updateRewardPoints(String userId, int pointsChange) async {
    try {
      final docRef = _db.collection(_rewardsCollection).doc(userId);
      final doc = await docRef.get();

      if (doc.exists) {
        final currentPoints = doc.data()?['points'] ?? 0;
        final newPoints = currentPoints + pointsChange;
        await docRef.update({
          'points': newPoints < 0 ? 0 : newPoints,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.set({
          'userId': userId,
          'points': pointsChange < 0 ? 0 : pointsChange,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      print('Error updating reward points: $e');
      return false;
    }
  }

  /// Set reward points to specific value
  /// Example: await DatabaseService.instance.setRewardPoints('user123', 500);
  Future<bool> setRewardPoints(String userId, int points) async {
    try {
      await _db.collection(_rewardsCollection).doc(userId).set({
        'userId': userId,
        'points': points < 0 ? 0 : points,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error setting reward points: $e');
      return false;
    }
  }

  /// Get reward points with real-time updates (Stream)
  /// Example: StreamBuilder(stream: DatabaseService.instance.getRewardPointsStream('user123'), ...)
  Stream<int> getRewardPointsStream(String userId) {
    return _db
        .collection(_rewardsCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['points'] ?? 0);
  }

  // ============================================================================
  // HELPER FUNCTIONS
  // ============================================================================

  /// Delete user and all associated data (GDPR compliance)
  /// Example: await DatabaseService.instance.deleteUserData('user123');
  Future<bool> deleteUserData(String userId) async {
    try {
      final batch = _db.batch();

      // Delete user document
      batch.delete(_db.collection(_usersCollection).doc(userId));

      // Delete cart items
      final cartSnapshot = await _db
          .collection(_cartCollection)
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete rewards
      batch.delete(_db.collection(_rewardsCollection).doc(userId));

      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting user data: $e');
      return false;
    }
  }

  /// Check if document exists
  /// Example: bool exists = await DatabaseService.instance.documentExists('users', 'user123');
  Future<bool> documentExists(String collection, String docId) async {
    try {
      final doc = await _db.collection(collection).doc(docId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking document existence: $e');
      return false;
    }
  }
}
