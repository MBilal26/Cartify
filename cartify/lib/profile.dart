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
  bool isEmailVerified = false;

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
        final userData = await DatabaseService.instance.getUser(userId!);
        final balance = await DatabaseService.instance.getWalletBalance(
          userId!,
        );

        if (userData != null && mounted) {
          setState(() {
            userName = userData['name'] ?? 'User';
            userEmail = userData['email'] ?? '';
            userAddress = userData['address'];
            isEmailVerified = userData['emailVerified'] ?? false;
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
          isEmailVerified = false;
          _isLoading = false;
        });
      }
    }
  }

  void _showWalletDialog() {
    if (userId == null) {
      _showErrorSnackBar('Please login first');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardForPage(pageId),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppColors.getAccentForPage(pageId),
            ),
            SizedBox(width: 8),
            Text(
              "My Wallet",
              style: TextStyle(
                fontFamily: 'IrishGrover',
                color: AppColors.getTextPrimaryForPage(pageId),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.getAccentForPage(pageId),
                      AppColors.getAccentForPage(pageId).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
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
                  color: AppColors.getTextSecondaryForPage(pageId),
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
              style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getAccentForPage(pageId),
            ),
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
            backgroundColor: AppColors.getCardForPage(pageId),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Add Money to Wallet",
              style: TextStyle(
                fontFamily: 'IrishGrover',
                color: AppColors.getTextPrimaryForPage(pageId),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(pageId),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount (Rs.)',
                      labelStyle: TextStyle(
                        color: AppColors.getTextSecondaryForPage(pageId),
                      ),
                      prefixIcon: Icon(
                        Icons.money,
                        color: AppColors.getAccentForPage(pageId),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.getBorderForPage(pageId),
                        ),
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
                          color: AppColors.getAccentForPage(pageId),
                          fontFamily: 'ADLaMDisplay',
                        ),
                        backgroundColor: AppColors.getAccentForPage(
                          pageId,
                        ).withOpacity(0.1),
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
                  style: TextStyle(
                    color: AppColors.getTextPrimaryForPage(pageId),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getAccentForPage(pageId),
                ),
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    Navigator.pop(context);
                    _showErrorSnackBar('Please enter a valid amount');
                    return;
                  }

                  try {
                    await DatabaseService.instance.addToWallet(
                      uid: userId!,
                      amount: amount,
                    );
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
          backgroundColor: AppColors.getCardForPage(pageId),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                          color: AppColors.getTextPrimaryForPage(pageId),
                          fontSize: 12,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Profile information\n• Order history\n• Reward points\n• Cart items\n• Wallet balance',
                        style: TextStyle(
                          color: AppColors.getTextSecondaryForPage(pageId),
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
                    color: AppColors.getTextPrimaryForPage(pageId),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(
                    color: AppColors.getTextPrimaryForPage(pageId),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Your password',
                    hintStyle: TextStyle(
                      color: AppColors.getTextSecondaryForPage(pageId),
                    ),
                    prefixIcon: Icon(Icons.lock, color: AppColors.error),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getBorderForPage(pageId),
                      ),
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
                style: TextStyle(
                  color: AppColors.getTextPrimaryForPage(pageId),
                ),
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
                        if (user == null) throw Exception('No user logged in');

                        final credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: passwordController.text,
                        );
                        await user.reauthenticateWithCredential(credential);
                        await _deleteAllUserData(user.uid);
                        await user.delete();

                        passwordController.dispose();

                        if (mounted) {
                          Navigator.of(context).pop();
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/login', (route) => false);
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
                        setDialogState(() => isDeleting = false);
                        String message = 'Failed to delete account';
                        if (e.code == 'wrong-password')
                          message = 'Incorrect password';
                        else if (e.code == 'too-many-requests')
                          message = 'Too many attempts. Try again later';
                        else if (e.code == 'requires-recent-login')
                          message =
                              'Please logout, login again, then try deleting';

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

  Future<void> _deleteAllUserData(String uid) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      batch.delete(userRef);

      final cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: uid)
          .get();
      for (var doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final rewardsRef = FirebaseFirestore.instance
          .collection('rewards')
          .doc(uid);
      batch.delete(rewardsRef);

      final otpRef = FirebaseFirestore.instance
          .collection('otp_verifications')
          .doc(uid);
      batch.delete(otpRef);

      await batch.commit();

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
        }
      } catch (e) {
        print('No coupons to delete or error: $e');
      }
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  void _addNewAddress() async {
    if (userId == null) {
      _showErrorSnackBar('Please login first');
      return;
    }

    final controller = TextEditingController(text: userAddress ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardForPage(pageId),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Add Address",
          style: TextStyle(
            fontFamily: 'IrishGrover',
            color: AppColors.getTextPrimaryForPage(pageId),
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Enter your address',
            hintStyle: TextStyle(
              color: AppColors.getTextSecondaryForPage(pageId),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getAccentForPage(pageId),
            ),
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
        backgroundColor: AppColors.getCardForPage(pageId),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontFamily: 'IrishGrover',
            color: AppColors.getTextPrimaryForPage(pageId),
          ),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)),
          decoration: InputDecoration(
            labelText: "Name",
            labelStyle: TextStyle(
              color: AppColors.getTextSecondaryForPage(pageId),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getAccentForPage(pageId),
            ),
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
        backgroundColor: AppColors.getCardForPage(pageId),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Change Password",
          style: TextStyle(
            fontFamily: 'IrishGrover',
            color: AppColors.getTextPrimaryForPage(pageId),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                style: TextStyle(
                  color: AppColors.getTextPrimaryForPage(pageId),
                ),
                decoration: InputDecoration(
                  labelText: "Current Password",
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondaryForPage(pageId),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                style: TextStyle(
                  color: AppColors.getTextPrimaryForPage(pageId),
                ),
                decoration: InputDecoration(
                  labelText: "New Password",
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondaryForPage(pageId),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                style: TextStyle(
                  color: AppColors.getTextPrimaryForPage(pageId),
                ),
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  labelStyle: TextStyle(
                    color: AppColors.getTextSecondaryForPage(pageId),
                  ),
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
              style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getAccentForPage(pageId),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage(pageId),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.getAccentForPage(pageId),
              ),
            )
          : CustomScrollView(
              slivers: [
                // Modern App Bar with gradient
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: AppColors.getAccentForPage(pageId),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.splashBackgroundForPage(pageId),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 40),
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 42,
                                    backgroundColor:
                                        AppColors.getBackgroundForPage(pageId),
                                    child: Text(
                                      userName.isNotEmpty
                                          ? userName[0].toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.getAccentForPage(
                                          pageId,
                                        ),
                                        fontFamily: 'IrishGrover',
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: isEmailVerified
                                            ? AppColors.success
                                            : AppColors.error,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        isEmailVerified
                                            ? Icons.check
                                            : Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              userName,
                              style: TextStyle(
                                fontFamily: 'IrishGrover',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextPrimaryForPage(pageId),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontFamily: 'ADLaMDisplay',
                                fontSize: 14,
                                color: AppColors.getTextPrimaryForPage(pageId),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Wallet Card
                        _buildWalletCard(),

                        SizedBox(height: 24),

                        // Address Section
                        Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimaryForPage(pageId),
                            fontFamily: 'IrishGrover',
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildAddressCard(),

                        SizedBox(height: 24),

                        // Account Settings
                        Text(
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextPrimaryForPage(pageId),
                            fontFamily: 'IrishGrover',
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildSettingsCard(),

                        SizedBox(height: 24),

                        // Actions
                        _buildActionButtons(),

                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.getAccentForPage(pageId),
            AppColors.getAccentForPage(pageId).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.getAccentForPage(pageId).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showWalletDialog,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(width: 20),
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
                      SizedBox(height: 6),
                      Text(
                        'Rs. ${walletBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'IrishGrover',
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardForPage(pageId),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderForPage(pageId), width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.getAccentForPage(pageId).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.getAccentForPage(pageId),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userAddress ?? "No address added yet",
                        style: TextStyle(
                          fontFamily: 'ADLaMDisplay',
                          fontSize: 14,
                          color: userAddress != null
                              ? AppColors.getTextPrimaryForPage(pageId)
                              : AppColors.getTextSecondaryForPage(pageId),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.getAccentForPage(pageId),
                  ),
                  onPressed: _addNewAddress,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.getBorderForPage(pageId)),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _selectAddressFromMap,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      color: AppColors.getAccentForPage(pageId),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Select from Map',
                      style: TextStyle(
                        fontFamily: 'ADLaMDisplay',
                        fontSize: 14,
                        color: AppColors.getAccentForPage(pageId),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardForPage(pageId),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderForPage(pageId), width: 1),
      ),
      child: Column(
        children: [
          _settingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: _editProfileDetails,
            isFirst: true,
          ),
          _settingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: _changePassword,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(16) : Radius.zero,
          bottom: isLast ? Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: !isLast
                ? Border(
                    bottom: BorderSide(
                      color: AppColors.getBorderForPage(pageId),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.getAccentForPage(pageId).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.getAccentForPage(pageId),
                  size: 22,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'ADLaMDisplay',
                    fontSize: 15,
                    color: AppColors.getTextPrimaryForPage(pageId),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.getTextSecondaryForPage(pageId),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _actionButton(
          text: 'Logout',
          icon: Icons.logout,
          color: AppColors.getAccentForPage(pageId),
          onTap: _logout,
        ),
        SizedBox(height: 12),
        _actionButton(
          text: 'Delete Account',
          icon: Icons.delete_forever,
          color: AppColors.error,
          onTap: _showDeleteAccountDialog,
        ),
      ],
    );
  }

  Widget _actionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 22),
        label: Text(
          text,
          style: TextStyle(
            fontFamily: 'ADLaMDisplay',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
          shadowColor: color.withOpacity(0.3),
        ),
      ),
    );
  }
}
