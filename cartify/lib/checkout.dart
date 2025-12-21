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

  // New Controllers for Card Details
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

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
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
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
          content: Text(
            'Please login to place an order',
            style: TextStyle(fontFamily: 'ADLaMDisplay'),
          ),
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
            content: Text(
              'Your cart is empty',
              style: TextStyle(fontFamily: 'ADLaMDisplay'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      int total = 0;
      List<Map<String, dynamic>> orderItems = [];

      for (var cartItem in cartItems) {
        final product = await DatabaseService.instance.getProduct(
          cartItem['productId'],
        );

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
            content: Text(
              'Failed to place order. Please try again.',
              style: TextStyle(fontFamily: 'ADLaMDisplay'),
            ),
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
          content: Text(
            'Error: $e',
            style: TextStyle(fontFamily: 'ADLaMDisplay'),
          ),
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
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'IrishGrover',
            fontWeight: FontWeight.bold,
          ),
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
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'ADLaMDisplay',
                    ),
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
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      nameController,
                      'Full Name',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      phoneController,
                      'Phone Number',
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      addressController,
                      'Delivery Address',
                      Icons.home_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                    const SizedBox(height: 8),
                    RadioListTile(
                      value: 'Cash on Delivery',
                      groupValue: paymentMethod,
                      title: Text(
                        'Cash on Delivery',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                      onChanged: (value) =>
                          setState(() => paymentMethod = value!),
                      activeColor: AppColors.accent,
                    ),
                    RadioListTile(
                      value: 'Card Payment',
                      groupValue: paymentMethod,
                      title: Text(
                        'Card Payment',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                      onChanged: (value) =>
                          setState(() => paymentMethod = value!),
                      activeColor: AppColors.accent,
                    ),

                    // Card Details Section
                    if (paymentMethod == 'Card Payment') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildTextField(
                              cardNumberController,
                              'Card Number',
                              Icons.credit_card,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    expiryController,
                                    'MM/YY',
                                    Icons.calendar_today,
                                    keyboardType: TextInputType.datetime,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    cvvController,
                                    'CVV',
                                    Icons.lock_outline,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
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

  // Helper Widget for TextFields
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontFamily: 'ADLaMDisplay',
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.accent),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'ADLaMDisplay',
        ),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildOrderSummary() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getCartSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
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
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
                SizedBox(height: 12),
                ...items.map(
                  (item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item['name']} x${item['quantity']}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'ADLaMDisplay',
                          ),
                        ),
                        Text(
                          'Rs. ${item['price'] * item['quantity']}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'ADLaMDisplay',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                    Text(
                      'Rs. $total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                        fontFamily: 'ADLaMDisplay',
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
    );
  }

  Future<List<Map<String, dynamic>>> _getCartSummary() async {
    if (userId == null) return [];
    final cartItems = await DatabaseService.instance.getCartItems(userId!);
    List<Map<String, dynamic>> items = [];
    for (var cartItem in cartItems) {
      final product = await DatabaseService.instance.getProduct(
        cartItem['productId'],
      );
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
            Text(
              'Order Placed',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your order has been placed successfully!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Order ID: $orderId',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
            Text(
              'Total Amount: Rs. $total',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'ADLaMDisplay',
              ),
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
                      fontFamily: 'ADLaMDisplay',
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
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.accent,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
