import 'app_imports.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? userId;
  final String pageId = 'CART';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage(pageId),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.getAccentForPage(pageId),
        title: Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'IrishGrover',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: userId == null ? _buildLoginPrompt() : _buildCartStream(),
    );
  }

  // 1. Login Prompt
  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_person_outlined,
              size: 100,
              color: Colors.grey.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is locked',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'ADLaMDisplay',
                color: AppColors.getTextPrimaryForPage(pageId),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please login to see items you have added to your cart and start shopping.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.getTextSecondaryForPage(pageId),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getAccentForPage(pageId),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Login Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Main Cart Stream logic ---
  Widget _buildCartStream() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseService.instance.getCartItemsStream(userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.getAccentForPage(pageId),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong. Please try again.'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _getCartItemsWithProducts(snapshot.data!),
          builder: (context, productSnapshot) {
            if (productSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.getAccentForPage(pageId),
                ),
              );
            }

            final items = productSnapshot.data ?? [];
            if (items.isEmpty) return _buildEmptyState();

            int totalPrice = _calculateTotal(items);

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _buildCartItem(items[index]),
                  ),
                ),
                _buildCheckoutSection(totalPrice),
              ],
            );
          },
        );
      },
    );
  }

  // 3. Individual Product Card in Cart
  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getCardForPage(pageId),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: item['imageUrl'] != null && item['imageUrl'].isNotEmpty
                ? Image.network(
                    item['imageUrl'],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 90,
                    height: 90,
                    color: AppColors.getBorderForPage(pageId).withOpacity(0.3),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 16),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'] ?? 'Product',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'ADLaMDisplay',
                          color: AppColors.getTextPrimaryForPage(pageId),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 22,
                      ),
                      onPressed: () => DatabaseService.instance.removeFromCart(
                        userId: userId!,
                        productId: item['productId'],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Rs. ${item['price']}',
                  style: TextStyle(
                    color: AppColors.getAccentForPage(pageId),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                // Quantity Selector Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getBackgroundForPage(pageId),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          _quantityActionBtn(Icons.remove, () async {
                            if (item['quantity'] > 1) {
                              await DatabaseService.instance.updateCartQuantity(
                                userId: userId!,
                                productId: item['productId'],
                                quantity: item['quantity'] - 1,
                              );
                            }
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item['quantity']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.getTextPrimaryForPage(pageId),
                              ),
                            ),
                          ),
                          _quantityActionBtn(Icons.add, () async {
                            await DatabaseService.instance.updateCartQuantity(
                              userId: userId!,
                              productId: item['productId'],
                              quantity: item['quantity'] + 1,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityActionBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.getAccentForPage(pageId).withOpacity(0.1),
        ),
        child: Icon(icon, size: 16, color: AppColors.getAccentForPage(pageId)),
      ),
    );
  }

  // --- 4. Bottom Checkout Bar ---
  Widget _buildCheckoutSection(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.getCardForPage(pageId),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Rs. $total',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getAccentForPage(pageId),
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getAccentForPage(pageId),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'PROCEED TO CHECKOUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 5. Empty State Widget ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 120,
            color: Colors.grey.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'IrishGrover',
              color: AppColors.getTextPrimaryForPage(pageId).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            child: Text(
              'Start Shopping',
              style: TextStyle(
                color: AppColors.getAccentForPage(pageId),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Fetch Product Data for Cart IDs
  Future<List<Map<String, dynamic>>> _getCartItemsWithProducts(
    List<Map<String, dynamic>> cartItems,
  ) async {
    List<Map<String, dynamic>> itemsWithProducts = [];

    for (var cartItem in cartItems) {
      final productId = cartItem['productId'];
      final product = await DatabaseService.instance.getProduct(productId);

      if (product != null) {
        itemsWithProducts.add({
          'productId': productId,
          'name': product['name'],
          'price': product['price'],
          'imageUrl': product['imageUrl'],
          'quantity': cartItem['quantity'],
        });
      }
    }
    return itemsWithProducts;
  }

  //Helper: Total Calculation
  int _calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(0, (sum, item) {
      int price = (item['price'] is int)
          ? item['price']
          : int.tryParse(item['price'].toString()) ?? 0;
      int qty = (item['quantity'] is int) ? item['quantity'] : 1;
      return sum + (price * qty);
    });
  }
}
