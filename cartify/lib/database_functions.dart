import 'app_imports.dart';

class DatabaseService {
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
  final String _otpVerificationsCollection = 'otp_verifications';

  // =========================
  // OTP VERIFICATION FUNCTIONS
  // =========================
  Future<bool> storeOTP({
    required String userId,
    required String otp,
    required String email,
  }) async {
    try {
      await _db.collection(_otpVerificationsCollection).doc(userId).set({
        'otp': otp,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now()
            .add(const Duration(minutes: 10))
            .toIso8601String(),
        'verified': false,
      });
      return true;
    } catch (e) {
      print('Error storing OTP: $e');
      return false;
    }
  }

  /// Verify OTP for a user
  Future<bool> verifyOTP({required String userId, required String otp}) async {
    try {
      final doc = await _db
          .collection(_otpVerificationsCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      final storedOTP = data['otp'] as String;
      final expiresAt = DateTime.parse(data['expiresAt'] as String);

      // Check if OTP has expired
      if (DateTime.now().isAfter(expiresAt)) {
        return false;
      }

      // Check if OTP matches
      if (otp != storedOTP) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  /// Mark OTP as verified and update user email verification status
  Future<bool> markOTPVerified(String userId) async {
    try {
      // Update OTP verification document
      await _db.collection(_otpVerificationsCollection).doc(userId).update({
        'verified': true,
      });

      // Update user document
      await _db.collection(_usersCollection).doc(userId).update({
        'emailVerified': true,
      });

      return true;
    } catch (e) {
      print('Error marking OTP as verified: $e');
      return false;
    }
  }

  /// Delete OTP document after verification or expiry
  Future<bool> deleteOTP(String userId) async {
    try {
      await _db.collection(_otpVerificationsCollection).doc(userId).delete();
      return true;
    } catch (e) {
      print('Error deleting OTP: $e');
      return false;
    }
  }

  /// Check if user's email is verified
  Future<bool> isEmailVerified(String userId) async {
    try {
      final doc = await _db.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        return doc.data()?['emailVerified'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  // ====================
  // COUPONS COLLECTION
  // ====================
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

    // Check if already used
    if (data['used'] == true) return null;

    // Check expiry (if exists)
    if (data.containsKey('expiresAt')) {
      final expiry = (data['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiry)) return null;
    }

    return {'code': doc.id, 'discountPercent': data['discountPercent']};
  }

  // =================
  // WALLET FUNCTIONS
  // =================
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
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'walletBalance': newBalance,
    });
  }

  Future<void> addToWallet({
    required String uid,
    required double amount,
  }) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      final current = (snapshot.data()?['walletBalance'] ?? 0).toDouble();
      tx.update(ref, {'walletBalance': current + amount});
    });
  }

  // ==========================================================
  // FIREBASE STORAGE FUNCTIONS (For uploading product images)
  // ==========================================================
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
        .doc();

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

  // =================
  // USERS COLLECTION
  // =================
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
        'emailVerified': false, // Set to false initially
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  /// Get user information
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

  // ======================
  // CATEGORIES COLLECTION
  // ======================

  /// Get categories as a LIVE Stream
  Stream<List<Map<String, dynamic>>> getCategoriesStream() {
    return _db
        .collection(_categoriesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  /// Add a new category
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

  /// Delete category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _db.collection(_categoriesCollection).doc(categoryId).delete();
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  /// Delete Parent Category AND its Subcategories
  Future<bool> deleteParentCategory({
    required String parentId,
    required String parentTitle,
  }) async {
    try {
      final batch = _db.batch();

      // 1. Delete the Parent Category Document
      final parentRef = _db.collection(_categoriesCollection).doc(parentId);
      batch.delete(parentRef);

      // 2. Find and Delete all Subcategories linked to this parent
      final subCategoriesSnapshot = await _db
          .collection(_categoriesCollection)
          .where('parentCategory', isEqualTo: parentTitle)
          .get();

      for (var doc in subCategoriesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 3. Commit the batch (All or nothing)
      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting parent category and subcategories: $e');
      return false;
    }
  }

  /// Get all categories
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

  /// Get categories by parent
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

  // ====================
  // PRODUCTS COLLECTION
  // ====================

  /// Add a new product
  Future<String?> addProduct({
    required String name,
    required int price,
    required String categoryId,
    String? gender,
    String? imageUrl,
    String? description,
  }) async {
    try {
      final docRef = await _db.collection(_productsCollection).add({
        'name': name,
        'price': price,
        'categoryId': categoryId,
        'gender': gender,
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

  /// Update existing product
  Future<bool> updateProduct({
    required String productId,
    String? name,
    int? price,
    String? categoryId,
    String? gender,
    String? imageUrl,
    String? description,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (price != null) updates['price'] = price;
      if (categoryId != null) updates['categoryId'] = categoryId;
      if (gender != null) updates['gender'] = gender;
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

  // ================
  // CART COLLECTION
  // ================

  /// Add item to cart (or update quantity if already exists)
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

  // ===================
  // ORDERS COLLECTION
  // ===================

  /// Place a new order
  Future<String?> placeOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required int totalAmount,
    Map<String, dynamic>? paymentDetails, // <--- ADD THIS PARAMETER
  }) async {
    try {
      final orderRef = _db.collection(_ordersCollection).doc();

      await orderRef.set({
        'userId': userId,
        'items': items,
        'totalAmount': totalAmount,
        'status': 'Pending',
        'paymentDetails': paymentDetails,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return orderRef.id;
    } catch (e) {
      print('Error placing order: $e');
      return null;
    }
  }

  /// Get all orders for a user
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

  // ===================
  // REWARDS COLLECTION
  // ===================
  /// Get reward points for a user
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
  Stream<int> getRewardPointsStream(String userId) {
    return _db
        .collection(_rewardsCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['points'] ?? 0);
  }

  // =================
  // HELPER FUNCTIONS
  // =================
  /// Delete user and all associated data
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

      // Delete OTP verification
      batch.delete(_db.collection(_otpVerificationsCollection).doc(userId));

      await batch.commit();
      return true;
    } catch (e) {
      print('Error deleting user data: $e');
      return false;
    }
  }

  /// Check if document exists
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

class BannerService {
  BannerService._();
  static final BannerService instance = BannerService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save banner asset paths to Firestore
  Future<bool> saveBanners(List<String> bannerPaths) async {
    try {
      await _db.collection('app_settings').doc('banners').set({
        'paths': bannerPaths,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error saving banners: $e');
      return false;
    }
  }

  // Get banner asset paths from Firestore
  Future<List<String>> getBanners() async {
    try {
      final doc = await _db.collection('app_settings').doc('banners').get();
      if (doc.exists) {
        final data = doc.data();
        return List<String>.from(data?['paths'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting banners: $e');
      return [];
    }
  }

  // Save category cards
  Future<bool> saveCategoryCards(List<Map<String, String>> cards) async {
    try {
      await _db.collection('app_settings').doc('category_cards').set({
        'cards': cards,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error saving category cards: $e');
      return false;
    }
  }

  // Get category cards
  Future<List<Map<String, String>>> getCategoryCards() async {
    try {
      final doc = await _db
          .collection('app_settings')
          .doc('category_cards')
          .get();
      if (doc.exists) {
        final data = doc.data();
        final cards = data?['cards'] as List<dynamic>? ?? [];
        return cards.map((card) => Map<String, String>.from(card)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting category cards: $e');
      return [];
    }
  }

  // Save Cartify banner path
  Future<bool> saveCartifyBanner(String bannerPath) async {
    try {
      await _db.collection('app_settings').doc('cartify_banner').set({
        'path': bannerPath,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error saving Cartify banner: $e');
      return false;
    }
  }

  // Get Cartify banner path
  Future<String?> getCartifyBanner() async {
    try {
      final doc = await _db
          .collection('app_settings')
          .doc('cartify_banner')
          .get();
      if (doc.exists) {
        return doc.data()?['path'];
      }
      return null;
    } catch (e) {
      print('Error getting Cartify banner: $e');
      return null;
    }
  }
}
