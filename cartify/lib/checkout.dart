import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'database_functions.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  // User input controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String paymentMethod = 'Cash on Delivery';
  bool _isLoading = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (userId != null) {
      final userData = await DatabaseService.instance.getUser(userId!);
      if (userData != null) {
        setState(() {
          nameController.text = userData['name'] ?? '';
          addressController.text = userData['address'] ?? '';
        });
      }
    }
  }

  // Place order function
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to place an order'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get cart items
      final cartItems = await DatabaseService.instance.getCartItems(userId!);

      if (cartItems.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your cart is empty'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Calculate total and prepare order items
      int total = 0;
      List<Map<String, dynamic>> orderItems = [];

      for (var cartItem in cartItems) {
        // Get product details
        final product =
            await DatabaseService.instance.getProduct(cartItem['productId']);

        if (product != null) {
          int itemTotal = (product['price'] * cartItem['quantity']) as int;
          total += itemTotal;

          orderItems.add({
            'productId': cartItem['productId'],
            'name': product['name'],
            'price': product['price'],
            'quantity': cartItem['quantity'],
            'imageUrl': product['imageUrl'],
          });
        }
      }

      // Place the order
      final orderId = await DatabaseService.instance.placeOrder(
        userId: userId!,
        items: orderItems,
        totalAmount: total,
      );

      if (orderId != null) {
        // Update user address if changed
        await DatabaseService.instance.updateUser(
          uid: userId!,
          address: addressController.text.trim(),
        );

        // Clear cart after successful order
        await DatabaseService.instance.clearCart(userId!);

        // Add reward points (100 points per order)
        await DatabaseService.instance.updateRewardPoints(userId!, 100);

        setState(() {
          _isLoading = false;
        });

        // Show success dialog
        _showOrderSuccess(context, orderId, total);
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),

      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Placing your order...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SHIPPING DETAILS
                    const Text(
                      'Shipping Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter phone number' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter delivery address' : null,
                    ),

                    const SizedBox(height: 24),

                    // PAYMENT METHOD
                    const Text(
                      'Payment Method',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    RadioListTile(
                      value: 'Cash on Delivery',
                      groupValue: paymentMethod,
                      title: const Text('Cash on Delivery'),
                      onChanged: (value) {
                        setState(() {
                          paymentMethod = value!;
                        });
                      },
                    ),

                    RadioListTile(
                      value: 'Card Payment',
                      groupValue: paymentMethod,
                      title: const Text('Card Payment'),
                      onChanged: (value) {
                        setState(() {
                          paymentMethod = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // ORDER SUMMARY
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _getCartSummary(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          final items = snapshot.data!;
                          int total = _calculateTotal(items);

                          return Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Summary',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                ...items.map((item) => Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              '${item['name']} x${item['quantity']}'),
                                          Text(
                                              'Rs. ${item['price'] * item['quantity']}'),
                                        ],
                                      ),
                                    )),
                                Divider(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Rs. $total',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }

                        return SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 24),

                    // PLACE ORDER BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'PLACE ORDER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ADLaMDisplay',
                            color: AppColors.textSecondary,
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

  // Get cart summary
  Future<List<Map<String, dynamic>>> _getCartSummary() async {
    if (userId == null) return [];

    final cartItems = await DatabaseService.instance.getCartItems(userId!);
    List<Map<String, dynamic>> items = [];

    for (var cartItem in cartItems) {
      final product =
          await DatabaseService.instance.getProduct(cartItem['productId']);
      if (product != null) {
        items.add({
          'name': product['name'],
          'price': product['price'],
          'quantity': cartItem['quantity'],
        });
      }
    }

    return items;
  }

  // Calculate total
  int _calculateTotal(List<Map<String, dynamic>> items) {
    int total = 0;
    for (var item in items) {
      total += ((item['price'] ?? 0) * (item['quantity'] ?? 1)) as int;
    }
    return total;
  }

  // SUCCESS DIALOG
  void _showOrderSuccess(BuildContext context, String orderId, int total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('Order Placed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your order has been placed successfully!'),
            SizedBox(height: 12),
            Text('Order ID: $orderId',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Total Amount: Rs. $total'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.redeem, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'You earned 100 reward points!',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to previous page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}