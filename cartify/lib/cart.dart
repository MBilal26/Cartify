import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'database_functions.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'IrishGrover',
          ),
        ),
        centerTitle: true,
      ),

      body: userId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Please login to view your cart',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            )
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: DatabaseService.instance.getCartItemsStream(userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading cart: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final cartItems = snapshot.data!;

                // We need to fetch product details for each cart item
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getCartItemsWithProducts(cartItems),
                  builder: (context, productSnapshot) {
                    if (productSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!productSnapshot.hasData ||
                        productSnapshot.data!.isEmpty) {
                      return Center(child: Text('Your cart is empty'));
                    }

                    final itemsWithProducts = productSnapshot.data!;
                    int totalPrice = _calculateTotal(itemsWithProducts);

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: itemsWithProducts.length,
                            itemBuilder: (context, index) {
                              final item = itemsWithProducts[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        item['imageUrl'] != null &&
                                            item['imageUrl'].isNotEmpty
                                        ? Image.network(
                                            item['imageUrl'],
                                            width: 55,
                                            height: 55,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 55,
                                                    height: 55,
                                                    color: AppColors.border,
                                                    child: Icon(
                                                      Icons.image,
                                                      color: Colors.grey,
                                                    ),
                                                  );
                                                },
                                          )
                                        : Container(
                                            width: 55,
                                            height: 55,
                                            color: AppColors.border,
                                            child: Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  title: Text(
                                    item['name'] ?? 'Product',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Rs. ${item['price'] ?? 0}',
                                    style: TextStyle(color: AppColors.accent),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () async {
                                          if (item['quantity'] > 1) {
                                            await DatabaseService.instance
                                                .updateCartQuantity(
                                                  userId: userId!,
                                                  productId: item['productId'],
                                                  quantity:
                                                      item['quantity'] - 1,
                                                );
                                          }
                                        },
                                      ),
                                      Text(
                                        item['quantity'].toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () async {
                                          await DatabaseService.instance
                                              .updateCartQuantity(
                                                userId: userId!,
                                                productId: item['productId'],
                                                quantity: item['quantity'] + 1,
                                              );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: AppColors.error,
                                        ),
                                        onPressed: () async {
                                          await DatabaseService.instance
                                              .removeFromCart(
                                                userId: userId!,
                                                productId: item['productId'],
                                              );

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Item removed from cart',
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Total & Checkout
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, -6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Rs. $totalPrice',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/checkout');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text(
                                    'CHECKOUT',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                      fontFamily: 'ADLaMDisplay',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  // Helper function to get cart items with product details
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

  // Calculate total price
  int _calculateTotal(List<Map<String, dynamic>> items) {
    int total = 0;
    for (var item in items) {
      total += ((item['price'] ?? 0) * (item['quantity'] ?? 1)) as int;
    }
    return total;
  }
}
