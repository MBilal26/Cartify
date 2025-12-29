import 'app_imports.dart';

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

  // Card Details Controllers
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController couponController = TextEditingController();
  int discountPercent = 0;

  String paymentMethod = 'Cash on Delivery';
  bool _isLoading = false;
  String? userId;
  double walletBalance = 0.0;
  bool isLoadingWallet = true;

  // ✅ CONSTANT: Page ID for Colors
  final String pageId = 'CHECKOUT';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _loadUserData();
    _loadWalletBalance();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    couponController.dispose();
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

  Future<void> _loadWalletBalance() async {
    if (userId != null) {
      try {
        final balance = await DatabaseService.instance.getWalletBalance(
          userId!,
        );
        setState(() {
          walletBalance = balance;
          isLoadingWallet = false;
        });
      } catch (e) {
        print('Error loading wallet balance: $e');
        setState(() {
          walletBalance = 0.0;
          isLoadingWallet = false;
        });
      }
    } else {
      setState(() {
        isLoadingWallet = false;
      });
    }
  }

  // NEW: Open map to select address
  Future<void> _selectAddressFromMap() async {
    final selectedAddress = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapAddressPickerPage(currentAddress: addressController.text),
      ),
    );

    if (selectedAddress != null && selectedAddress.isNotEmpty) {
      setState(() {
        addressController.text = selectedAddress;
      });
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
      // 1. Prepare payment details map to store in the database
      Map<String, dynamic>? paymentDetails;

      if (paymentMethod == 'Card Payment') {
        paymentDetails = {
          'method': 'Credit/Debit Card',
          'cardNumber': cardNumberController.text.trim(),
          'expiryDate': expiryController.text.trim(),
          'cvv': cvvController.text
              .trim(), // Note: Storing CVV is usually for testing only
        };
      } else if (paymentMethod == 'Pay by Wallet') {
        paymentDetails = {'method': 'Wallet'};
      } else {
        paymentDetails = {'method': 'Cash on Delivery'};
      }

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

      int subtotal = 0;
      List<Map<String, dynamic>> orderItems = [];

      for (var cartItem in cartItems) {
        final product = await DatabaseService.instance.getProduct(
          cartItem['productId'],
        );

        if (product != null) {
          int itemTotal = (product['price'] * cartItem['quantity']) as int;
          subtotal += itemTotal;

          orderItems.add({
            'productId': cartItem['productId'],
            'name': product['name'],
            'price': product['price'],
            'quantity': cartItem['quantity'],
            'imageUrl': product['imageUrl'],
          });
        }
      }

      int discount = _calculateDiscount(subtotal);
      int total = subtotal - discount;

      // Check if paying with wallet
      if (paymentMethod == 'Pay by Wallet') {
        if (walletBalance < total) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Insufficient wallet balance. You need Rs. ${total - walletBalance.toInt()} more.',
                style: TextStyle(fontFamily: 'ADLaMDisplay'),
              ),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }

        // Deduct from wallet
        await DatabaseService.instance.updateWalletBalance(
          uid: userId!,
          newBalance: walletBalance - total,
        );
      }

      // 2. Pass the paymentDetails to the placeOrder function
      final orderId = await DatabaseService.instance.placeOrder(
        userId: userId!,
        items: orderItems,
        totalAmount: total,
        paymentDetails:
            paymentDetails, // <--- Ensure your DatabaseService accepts this
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
      backgroundColor: AppColors.getBackgroundForPage(pageId),
      appBar: AppBar(
        backgroundColor: AppColors.getAccentForPage(pageId),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'IrishGrover',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.getAccentForPage(pageId),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Placing your order...',
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(pageId),
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
                        color: AppColors.getTextPrimaryForPage(pageId),
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildTextField(
                      nameController,
                      'Full Name',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      phoneController,
                      'Phone Number',
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Address field with map button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: addressController,
                          maxLines: 3,
                          style: TextStyle(
                            color: AppColors.getTextPrimaryForPage(pageId),
                            fontFamily: 'ADLaMDisplay',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Delivery Address',
                            prefixIcon: Icon(
                              Icons.home_outlined,
                              color: AppColors.getAccentForPage(pageId),
                            ),
                            labelStyle: TextStyle(
                              color: AppColors.getTextSecondaryForPage(pageId),
                              fontFamily: 'ADLaMDisplay',
                            ),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.getBorderForPage(pageId),
                              ),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'This field is required' : null,
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _selectAddressFromMap,
                            icon: Icon(
                              Icons.map_outlined,
                              color: AppColors.getAccentForPage(pageId),
                            ),
                            label: Text(
                              'Select Address from Map',
                              style: TextStyle(
                                color: AppColors.getAccentForPage(pageId),
                                fontFamily: 'ADLaMDisplay',
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: AppColors.getAccentForPage(pageId),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimaryForPage(pageId),
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Cash on Delivery
                    RadioListTile(
                      value: 'Cash on Delivery',
                      groupValue: paymentMethod,
                      title: Text(
                        'Cash on Delivery',
                        style: TextStyle(
                          color: AppColors.getTextPrimaryForPage(pageId),
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                      onChanged: (value) =>
                          setState(() => paymentMethod = value!),
                      activeColor: AppColors.getAccentForPage(pageId),
                    ),

                    // Card Payment
                    RadioListTile(
                      value: 'Card Payment',
                      groupValue: paymentMethod,
                      title: Text(
                        'Card Payment',
                        style: TextStyle(
                          color: AppColors.getTextPrimaryForPage(pageId),
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                      onChanged: (value) =>
                          setState(() => paymentMethod = value!),
                      activeColor: AppColors.getAccentForPage(pageId),
                    ),

                    // Pay by Wallet - NEW
                    RadioListTile(
                      value: 'Pay by Wallet',
                      groupValue: paymentMethod,
                      title: Row(
                        children: [
                          Text(
                            'Pay by Wallet',
                            style: TextStyle(
                              color: AppColors.getTextPrimaryForPage(pageId),
                              fontFamily: 'ADLaMDisplay',
                            ),
                          ),
                          Spacer(),
                          if (isLoadingWallet)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.getAccentForPage(pageId),
                              ),
                            )
                          else
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: walletBalance > 0
                                    ? AppColors.getAccentForPage(
                                        pageId,
                                      ).withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Rs. ${walletBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: walletBalance > 0
                                      ? AppColors.getAccentForPage(pageId)
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  fontFamily: 'ADLaMDisplay',
                                ),
                              ),
                            ),
                        ],
                      ),
                      onChanged: (value) =>
                          setState(() => paymentMethod = value!),
                      activeColor: AppColors.getAccentForPage(pageId),
                    ),

                    // Card Details Section
                    if (paymentMethod == 'Card Payment') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.getCardForPage(pageId),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.getAccentForPage(
                              pageId,
                            ).withOpacity(0.5),
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

                    // Wallet Info Banner - NEW
                    if (paymentMethod == 'Pay by Wallet') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: walletBalance > 0
                              ? AppColors.getAccentForPage(
                                  pageId,
                                ).withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: walletBalance > 0
                                ? AppColors.getAccentForPage(
                                    pageId,
                                  ).withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              walletBalance > 0
                                  ? Icons.account_balance_wallet
                                  : Icons.warning_amber_rounded,
                              color: walletBalance > 0
                                  ? AppColors.getAccentForPage(pageId)
                                  : Colors.red,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                walletBalance > 0
                                    ? 'Payment will be deducted from your wallet balance'
                                    : 'Insufficient wallet balance. Please add money to your wallet or choose another payment method.',
                                style: TextStyle(
                                  color: walletBalance > 0
                                      ? AppColors.getTextPrimaryForPage(pageId)
                                      : Colors.red,
                                  fontSize: 13,
                                  fontFamily: 'ADLaMDisplay',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (walletBalance <= 0) ...[
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                            icon: Icon(
                              Icons.add,
                              color: AppColors.getAccentForPage(pageId),
                            ),
                            label: Text(
                              'Add Money to Wallet',
                              style: TextStyle(
                                color: AppColors.getAccentForPage(pageId),
                                fontFamily: 'ADLaMDisplay',
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: AppColors.getAccentForPage(pageId),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 24),
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.getAccentForPage(pageId),
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
        color: AppColors.getTextPrimaryForPage(pageId),
        fontFamily: 'ADLaMDisplay',
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.getAccentForPage(pageId)),
        labelStyle: TextStyle(
          color: AppColors.getTextSecondaryForPage(pageId),
          fontFamily: 'ADLaMDisplay',
        ),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.getBorderForPage(pageId)),
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
            child: CircularProgressIndicator(
              color: AppColors.getAccentForPage(pageId),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final items = snapshot.data!;
          int subtotal = _calculateSubtotal(items);
          int discount = _calculateDiscount(subtotal);
          int total = subtotal - discount;

          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getCardForPage(pageId),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.getBorderForPage(pageId)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimaryForPage(pageId),
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
                            color: AppColors.getTextPrimaryForPage(pageId),
                            fontFamily: 'ADLaMDisplay',
                          ),
                        ),
                        Text(
                          'Rs. ${item['price'] * item['quantity']}',
                          style: TextStyle(
                            color: AppColors.getTextPrimaryForPage(pageId),
                            fontFamily: 'ADLaMDisplay',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 20, color: AppColors.getBorderForPage(pageId)),
                SizedBox(height: 8),
                _buildCouponInput(),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: TextStyle(
                        fontFamily: 'ADLaMDisplay',
                        color: AppColors.getTextPrimaryForPage(pageId),
                      ),
                    ),
                    Text(
                      'Rs. $subtotal',
                      style: TextStyle(
                        fontFamily: 'ADLaMDisplay',
                        color: AppColors.getTextPrimaryForPage(pageId),
                      ),
                    ),
                  ],
                ),

                if (discountPercent > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discount ($discountPercent%)',
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                      Text(
                        '- Rs. $discount',
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                    ],
                  ),
                ],

                const Divider(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ADLaMDisplay',
                        color: AppColors.getTextPrimaryForPage(pageId),
                      ),
                    ),
                    Text(
                      'Rs. $total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getAccentForPage(pageId),
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

  int _calculateSubtotal(List<Map<String, dynamic>> items) {
    int total = 0;
    for (var item in items) {
      total += ((item['price'] ?? 0) * (item['quantity'] ?? 1)) as int;
    }
    return total;
  }

  int _calculateDiscount(int subtotal) {
    return ((subtotal * discountPercent) / 100).round();
  }

  void _applyCoupon() async {
    final couponData = await DatabaseService.instance.validateCoupon(
      couponController.text,
    );
    if (couponData != null) {
      setState(() {
        discountPercent = couponData['discountPercent'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Coupon Applied Successfully!"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid or Expired Coupon"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildCouponInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.getBorderForPage(pageId)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer, color: AppColors.getAccentForPage(pageId)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: TextStyle(
                color: AppColors.getTextPrimaryForPage(pageId),
                fontFamily: 'ADLaMDisplay',
                fontSize: 16,
              ),
              controller: couponController,
              decoration: InputDecoration(
                hintText: 'Coupon code',
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: _applyCoupon,
            child: Text(
              'APPLY',
              style: TextStyle(
                color: AppColors.getAccentForPage(pageId),
                fontWeight: FontWeight.bold,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderSuccess(BuildContext context, String orderId, int total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.getCardForPage(pageId),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text(
              'Order Placed',
              style: TextStyle(
                color: AppColors.getTextPrimaryForPage(pageId),
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
                color: AppColors.getTextPrimaryForPage(pageId),
                fontFamily: 'ADLaMDisplay',
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Order ID: $orderId',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimaryForPage(pageId),
                fontFamily: 'ADLaMDisplay',
              ),
            ),
            Text(
              'Total Amount: Rs. $total',
              style: TextStyle(
                color: AppColors.getTextPrimaryForPage(pageId),
                fontFamily: 'ADLaMDisplay',
              ),
            ),
            if (paymentMethod == 'Pay by Wallet') ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.getAccentForPage(pageId).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.getAccentForPage(pageId),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Paid via Wallet',
                        style: TextStyle(
                          color: AppColors.getAccentForPage(pageId),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ADLaMDisplay',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                color: AppColors.getAccentForPage(pageId),
                fontFamily: 'ADLaMDisplay',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
