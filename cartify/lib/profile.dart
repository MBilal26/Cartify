import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colors.dart';
import 'reset_password.dart';
import 'database_functions.dart';
import 'map_address_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String? userAddress;
  String? userId;
  bool _isLoading = true;
  double walletBalance = 0.0;

  // ✅ CONSTANT for this page colors
  final String pageId = 'PROFILE';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        // Load user data
        final userData = await DatabaseService.instance.getUser(userId!);

        // Load wallet balance
        final balance = await DatabaseService.instance.getWalletBalance(
          userId!,
        );

        if (userData != null && mounted) {
          setState(() {
            userName = userData['name'] ?? 'User';
            userEmail = userData['email'] ?? '';
            userAddress = userData['address'];
            walletBalance = balance;
            _isLoading = false;
          });
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } catch (e) {
        print('Error loading user data: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
            walletBalance = 0.0;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          userName = "Guest";
          userEmail = "Not logged in";
          _isLoading = false;
        });
      }
    }
  }

  // ===================== WALLET ACTIONS =====================

  void _showWalletDialog() {
    if (userId == null) {
      _showErrorSnackBar('Please login first');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardForPage(pageId), // ✅ UPDATED
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
            SizedBox(width: 8),
            Text(
              "My Wallet",
              style: TextStyle(
                fontFamily: 'IrishGrover',
                color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.getAccentForPage(pageId), // ✅ UPDATED
                      AppColors.getAccentForPage(pageId).withOpacity(0.7), // ✅ UPDATED
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rs. ${walletBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IrishGrover',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Add money to your wallet for faster checkout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
                  fontSize: 13,
                  fontFamily: 'ADLaMDisplay',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
            onPressed: () {
              Navigator.pop(context);
              _showAddMoneyDialog();
            },
            child: Text(
              'Add Money',
              style: TextStyle(color: Colors.white, fontFamily: 'ADLaMDisplay'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog() {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.getCardForPage(pageId), // ✅ UPDATED
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              "Add Money to Wallet",
              style: TextStyle(
                fontFamily: 'IrishGrover',
                color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
                    decoration: InputDecoration(
                      labelText: 'Amount (Rs.)',
                      labelStyle: TextStyle(color: AppColors.getTextSecondaryForPage(pageId)), // ✅ UPDATED
                      prefixIcon: Icon(Icons.money, color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.getBorderForPage(pageId)), // ✅ UPDATED
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [500, 1000, 2000, 5000].map((amount) {
                      return ActionChip(
                        label: Text('Rs. $amount'),
                        labelStyle: TextStyle(
                          color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                          fontFamily: 'ADLaMDisplay',
                        ),
                        backgroundColor: AppColors.getAccentForPage(pageId).withOpacity(0.1), // ✅ UPDATED
                        onPressed: () {
                          setDialogState(() {
                            amountController.text = amount.toString();
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                ),
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    Navigator.pop(context);
                    _showErrorSnackBar('Please enter a valid amount');
                    return;
                  }

                  try {
                    // Add to wallet in Firestore
                    await DatabaseService.instance.addToWallet(
                      uid: userId!,
                      amount: amount,
                    );

                    // Update local state
                    setState(() {
                      walletBalance += amount;
                    });

                    Navigator.pop(context);
                    _showSuccessSnackBar(
                      'Rs. ${amount.toStringAsFixed(2)} added to wallet!',
                    );
                  } catch (e) {
                    print('Error adding money: $e');
                    Navigator.pop(context);
                    _showErrorSnackBar('Failed to add money: $e');
                  }
                },
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ===================== DELETE ACCOUNT =====================

  void _showDeleteAccountDialog() {
    if (userId == null) {
      _showErrorSnackBar('Please login first');
      return;
    }

    final passwordController = TextEditingController();
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.getCardForPage(pageId), // ✅ UPDATED
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 28,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Delete Account",
                  style: TextStyle(
                    fontFamily: 'IrishGrover',
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This action cannot be undone!',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'All your data will be permanently deleted:',
                        style: TextStyle(
                          color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                          fontSize: 12,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Profile information\n'
                            '• Order history\n'
                            '• Reward points\n'
                            '• Cart items\n'
                            '• Wallet balance',
                        style: TextStyle(
                          color: AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
                          fontSize: 11,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Enter your password to confirm:',
                  style: TextStyle(
                    color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
                  decoration: InputDecoration(
                    hintText: 'Your password',
                    hintStyle: TextStyle(color: AppColors.getTextSecondaryForPage(pageId)), // ✅ UPDATED
                    prefixIcon: Icon(Icons.lock, color: AppColors.error),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.getBorderForPage(pageId)), // ✅ UPDATED
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDeleting
                  ? null
                  : () {
                passwordController.dispose();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                disabledBackgroundColor: Colors.grey,
              ),
              onPressed: isDeleting
                  ? null
                  : () async {
                if (passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter your password'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                setDialogState(() => isDeleting = true);

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    throw Exception('No user logged in');
                  }

                  print('🔄 Starting account deletion for: ${user.uid}');

                  // Step 1: Re-authenticate user FIRST
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: passwordController.text,
                  );

                  await user.reauthenticateWithCredential(credential);
                  print('✅ Re-authentication successful');

                  // Step 2: Delete all user data from Firestore WHILE STILL AUTHENTICATED
                  await _deleteAllUserData(user.uid);
                  print('✅ All user data deleted from Firestore');

                  // Step 3: NOW delete Firebase Auth account (this removes authentication)
                  await user.delete();
                  print('✅ Firebase Auth account deleted');

                  // Step 4: Cleanup and navigate
                  passwordController.dispose();

                  if (mounted) {
                    Navigator.of(context).pop(); // Close dialog

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                          (route) => false,
                    );

                    Future.delayed(Duration(milliseconds: 500), () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Account deleted successfully'),
                            backgroundColor: AppColors.success,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    });
                  }
                } on FirebaseAuthException catch (e) {
                  print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
                  setDialogState(() => isDeleting = false);

                  String message = 'Failed to delete account';
                  if (e.code == 'wrong-password') {
                    message = 'Incorrect password';
                  } else if (e.code == 'too-many-requests') {
                    message = 'Too many attempts. Try again later';
                  } else if (e.code == 'requires-recent-login') {
                    message = 'Please logout, login again, then try deleting';
                  } else if (e.code == 'user-mismatch') {
                    message = 'Authentication error. Please try again';
                  } else if (e.code == 'invalid-credential') {
                    message = 'Invalid credentials. Please check your password';
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: AppColors.error,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                } catch (e) {
                  print('❌ General Error: $e');
                  setDialogState(() => isDeleting = false);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              child: isDeleting
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'ADLaMDisplay',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// CRITICAL: This runs BEFORE deleting auth, so user is still authenticated
  Future<void> _deleteAllUserData(String uid) async {
    try {
      print('🔄 Starting Firestore data deletion (user still authenticated)...');

      // Use a single batch for better performance and atomicity
      final batch = FirebaseFirestore.instance.batch();
      int itemsToDelete = 0;

      // 1. Delete user document
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      batch.delete(userRef);
      itemsToDelete++;
      print('📝 Marked user document for deletion');

      // 2. Delete cart items - get all cart items for this user
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
        itemsToDelete++;
      }
      print('📝 Marked ${cartSnapshot.docs.length} cart items for deletion');

      // 3. Delete rewards
      final rewardsRef = FirebaseFirestore.instance.collection('rewards').doc(uid);
      batch.delete(rewardsRef);
      itemsToDelete++;
      print('📝 Marked rewards document for deletion');

      // 4. Delete OTP verifications
      final otpRef = FirebaseFirestore.instance
          .collection('otp_verifications')
          .doc(uid);
      batch.delete(otpRef);
      itemsToDelete++;
      print('📝 Marked OTP verification for deletion');

      // 5. Commit the main batch
      await batch.commit();
      print('✅ Batch commit successful! Deleted $itemsToDelete items');

      // 6. Delete user's coupons subcollection (separate batch for subcollections)
      try {
        final couponsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('coupons')
            .get();

        if (couponsSnapshot.docs.isNotEmpty) {
          final couponsBatch = FirebaseFirestore.instance.batch();
          for (var doc in couponsSnapshot.docs) {
            couponsBatch.delete(doc.reference);
          }
          await couponsBatch.commit();
          print('✅ Deleted ${couponsSnapshot.docs.length} user coupons');
        }
      } catch (e) {
        print('⚠️ No coupons to delete or error: $e');
      }

      // 7. OPTIONAL: Delete orders (uncomment if you want to delete order history)
      /*
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .get();

    if (ordersSnapshot.docs.isNotEmpty) {
      final ordersBatch = FirebaseFirestore.instance.batch();
      for (var doc in ordersSnapshot.docs) {
        ordersBatch.delete(doc.reference);
      }
      await ordersBatch.commit();
      print('✅ Deleted ${ordersSnapshot.docs.length} orders');
    }
    */

      print('✅ ALL user data successfully deleted from Firestore');
    } catch (e) {
      print('❌ Error deleting user data: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      throw Exception('Failed to delete user data: $e');
    }
  }

  // ===================== OTHER ACTIONS =====================

  void _addNewAddress() async {
    if (userId == null) {
      _showErrorSnackBar('Please login first');
      return;
    }

    final controller = TextEditingController(text: userAddress ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardForPage(pageId), // ✅ UPDATED
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          "Add Address",
          style: TextStyle(
            fontFamily: 'IrishGrover',
            color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
          ),
        ),
        content: SingleChildScrollView(
          child: TextField(
            controller: controller,
            maxLines: 3,
            style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'Enter your address',
              hintStyle: TextStyle(color: AppColors.getTextSecondaryForPage(pageId)), // ✅ UPDATED
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
            onPressed: () async {
              final newAddress = controller.text.trim();
              if (newAddress.isEmpty) {
                _showErrorSnackBar('Please enter an address');
                return;
              }

              final success = await DatabaseService.instance.updateUser(
                uid: userId!,
                address: newAddress,
              );

              if (success) {
                setState(() => userAddress = newAddress);
                Navigator.pop(context);
                _showSuccessSnackBar('Address updated successfully');
              } else {
                _showErrorSnackBar('Failed to update address');
              }
            },
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white, fontFamily: 'ADLaMDisplay'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAddressFromMap() async {
    if (userId == null) {
      _showErrorSnackBar('Please login first');
      return;
    }

    final selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapAddressPickerPage(currentAddress: userAddress),
      ),
    );

    if (selectedAddress != null && selectedAddress.isNotEmpty) {
      final success = await DatabaseService.instance.updateUser(
        uid: userId!,
        address: selectedAddress,
      );

      if (success) {
        setState(() => userAddress = selectedAddress);
        _showSuccessSnackBar('Address updated successfully!');
      } else {
        _showErrorSnackBar('Failed to update address');
      }
    }
  }

  void _editProfileDetails() async {
    if (userId == null) return;

    final nameController = TextEditingController(text: userName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardForPage(pageId), // ✅ UPDATED
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontFamily: 'IrishGrover',
            color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
          ),
        ),
        content: SingleChildScrollView(
          child: TextField(
            controller: nameController,
            style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
            decoration: InputDecoration(
              labelText: "Name",
              labelStyle: TextStyle(color: AppColors.getTextSecondaryForPage(pageId)), // ✅ UPDATED
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                _showErrorSnackBar('Please enter a name');
                return;
              }

              final success = await DatabaseService.instance.updateUser(
                uid: userId!,
                name: newName,
              );

              if (success) {
                setState(() => userName = newName);
                Navigator.pop(context);
                _showSuccessSnackBar('Profile updated successfully');
              } else {
                _showErrorSnackBar('Failed to update profile');
              }
            },
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white, fontFamily: 'ADLaMDisplay'),
            ),
          ),
        ],
      ),
    );
  }

  void _changePassword() async {
    if (userId == null) return;

    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardForPage(pageId), // ✅ UPDATED
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          "Change Password",
          style: TextStyle(
            fontFamily: 'IrishGrover',
            color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
                decoration: InputDecoration(
                  labelText: "Current Password",
                  labelStyle: TextStyle(color: AppColors.getTextSecondaryForPage(pageId)), // ✅ UPDATED
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
                decoration: InputDecoration(
                  labelText: "New Password",
                  labelStyle: TextStyle(color: AppColors.getTextSecondaryForPage(pageId)), // ✅ UPDATED
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  labelStyle: TextStyle(color: AppColors.getTextSecondaryForPage(pageId)), // ✅ UPDATED
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                  );
                },
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                    fontFamily: 'ADLaMDisplay',
                    color: AppColors.textaccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
            onPressed: () async {
              if (newController.text.length < 6) {
                _showErrorSnackBar('Password must be at least 6 characters');
                return;
              }

              if (newController.text != confirmController.text) {
                _showErrorSnackBar('Passwords do not match');
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                final credential = EmailAuthProvider.credential(
                  email: userEmail,
                  password: currentController.text,
                );

                await user!.reauthenticateWithCredential(credential);
                await user.updatePassword(newController.text);
                await DatabaseService.instance.updateUser(
                  uid: userId!,
                  password: newController.text,
                );

                Navigator.pop(context);
                _showSuccessSnackBar('Password updated successfully');
              } on FirebaseAuthException catch (e) {
                String message = 'Failed to update password';
                if (e.code == 'wrong-password') {
                  message = 'Current password is incorrect';
                }
                _showErrorSnackBar(message);
              }
            },
            child: Text(
              "Update",
              style: TextStyle(color: Colors.white, fontFamily: 'ADLaMDisplay'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ===================== HELPER METHODS =====================

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'ADLaMDisplay')),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'ADLaMDisplay')),
        backgroundColor: AppColors.error,
      ),
    );
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage(pageId), // ✅ UPDATED
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.getAccentForPage(pageId))) // ✅ UPDATED
          : SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppGradients.splashBackgroundForPage(pageId), // ✅ UPDATED
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.getBackgroundForPage(pageId), // ✅ UPDATED
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName,
                    style: TextStyle(
                      fontFamily: 'IrishGrover',
                      fontSize: 26,
                      color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontFamily: 'ADLaMDisplay',
                      color: AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
                    ),
                  ),
                ],
              ),
            ),

            // WALLET CARD
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: InkWell(
                onTap: _showWalletDialog,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.getAccentForPage(pageId), // ✅ UPDATED
                        AppColors.getAccentForPage(pageId).withOpacity(0.8), // ✅ UPDATED
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getAccentForPage(pageId).withOpacity(0.3), // ✅ UPDATED
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet Balance',
                              style: TextStyle(
                                fontFamily: 'ADLaMDisplay',
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Rs. ${walletBalance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: 'IrishGrover',
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // ADDRESS CARD
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.getCardForPage(pageId), // ✅ UPDATED
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.getBorderForPage(pageId)), // ✅ UPDATED
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Delivery Address",
                                style: TextStyle(
                                  fontFamily: 'IrishGrover',
                                  fontSize: 16,
                                  color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                userAddress ?? "No address added yet",
                                style: TextStyle(
                                  fontFamily: 'ADLaMDisplay',
                                  color: AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _selectAddressFromMap,
                      icon: Icon(Icons.map_outlined, color: Colors.white),
                      label: Text(
                        'Select Address from Map',
                        style: TextStyle(
                          fontFamily: 'ADLaMDisplay',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ACTIONS
            _actionTile(
              Icons.add_location_alt,
              "Add New Address",
              _addNewAddress,
            ),
            _actionTile(
              Icons.edit,
              "Edit Profile Details",
              _editProfileDetails,
            ),
            _actionTile(Icons.lock, "Change Password", _changePassword),

            SizedBox(height: 30),

            // ACTION BUTTONS
            _authPillButton(
              text: "Logout",
              icon: Icons.logout,
              backgroundColor: AppColors.error,
              textColor: Colors.white,
              onTap: _logout,
            ),

            SizedBox(height: 16),

            _authPillButton(
              text: "Delete Account",
              icon: Icons.delete_forever,
              backgroundColor: AppColors.error,
              textColor: Colors.white,
              onTap: _showDeleteAccountDialog,
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String text, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.getCardForPage(pageId), // ✅ UPDATED
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.getBorderForPage(pageId)), // ✅ UPDATED
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'ADLaMDisplay',
                    fontSize: 16,
                    color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.getTextSecondaryForPage(pageId)), // ✅ UPDATED
            ],
          ),
        ),
      ),
    );
  }

  Widget _authPillButton({
    required String text,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 200,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor),
        label: Text(
          text,
          style: TextStyle(
            fontFamily: 'ADLaMDisplay',
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}