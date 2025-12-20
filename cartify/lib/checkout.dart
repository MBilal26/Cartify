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

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
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

      int total = 0;
      List<Map<String, dynamic>> orderItems = [];

      for (var cartItem in cartItems) {
        final product = await DatabaseService.instance.getProduct(cartItem['productId']);

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

      final orderId = await DatabaseService.instance.placeOrder(
        userId: userId!,
        items: orderItems,
        totalAmount: total,
      );

      if (orderId != null) {
        await DatabaseService.instance.updateUser(
          uid: userId!,
          address: addressController.text.trim(),
        );

        await DatabaseService.instance.clearCart(userId!);
        await DatabaseService.instance.updateRewardPoints(userId!, 100);

        setState(() {
          _isLoading = false;
        });

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

      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Checkout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 16),
                  Text(
                    'Placing your order...',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
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
                    Text(
                      'Shipping Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: nameController,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter phone number' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: addressController,
                      maxLines: 3,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Delivery Address',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter delivery address' : null,
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    RadioListTile(
                      value: 'Cash on Delivery',
                      groupValue: paymentMethod,
                      title: Text(
                        'Cash on Delivery',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      onChanged: (value) {
                        setState(() {
                          paymentMethod = value!;
                        });
                      },
                      activeColor: AppColors.accent,
                    ),

                    RadioListTile(
                      value: 'Card Payment',
                      groupValue: paymentMethod,
                      title: Text(
                        'Card Payment',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      onChanged: (value) {
                        setState(() {
                          paymentMethod = value!;
                        });
                      },
                      activeColor: AppColors.accent,
                    ),

                    const SizedBox(height: 24),

                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _getCartSummary(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: AppColors.accent));
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
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 12),
                                ...items.map((item) => Padding(
                                      padding: EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${item['name']} x${item['quantity']}',
                                            style: TextStyle(color: AppColors.textPrimary),
                                          ),
                                          Text(
                                            'Rs. ${item['price'] * item['quantity']}',
                                            style: TextStyle(color: AppColors.textPrimary),
                                          ),
                                        ],
                                      ),
                                    )),
                                Divider(height: 20, color: AppColors.border),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
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
                            color: Colors.white,
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

  Future<List<Map<String, dynamic>>> _getCartSummary() async {
    if (userId == null) return [];

    final cartItems = await DatabaseService.instance.getCartItems(userId!);
    List<Map<String, dynamic>> items = [];

    for (var cartItem in cartItems) {
      final product = await DatabaseService.instance.getProduct(cartItem['productId']);
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

  int _calculateTotal(List<Map<String, dynamic>> items) {
    int total = 0;
    for (var item in items) {
      total += ((item['price'] ?? 0) * (item['quantity'] ?? 1)) as int;
    }
    return total;
  }

  void _showOrderSuccess(BuildContext context, String orderId, int total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('Order Placed', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your order has been placed successfully!',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            SizedBox(height: 12),
            Text(
              'Order ID: $orderId',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Total Amount: Rs. $total',
              style: TextStyle(color: AppColors.textPrimary),
            ),
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}