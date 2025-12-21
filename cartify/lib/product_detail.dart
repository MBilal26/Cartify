import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'colors.dart';
import 'database_functions.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? userId;
  String? userName;
  int quantity = 1;
  String? categoryName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _loadUserAndCategoryData();
  }

  Future<void> _loadUserAndCategoryData() async {
    // Load user name
    if (userId != null) {
      final userData = await DatabaseService.instance.getUser(userId!);
      if (userData != null && mounted) {
        setState(() {
          userName = userData['name'] ?? 'User';
        });
      }
    }

    // Load category name
    if (widget.product['categoryId'] != null) {
      final categories = await DatabaseService.instance.getCategories();
      final category = categories.firstWhere(
        (cat) => cat['id'] == widget.product['categoryId'],
        orElse: () => {},
      );

      if (category.isNotEmpty && mounted) {
        setState(() {
          categoryName = category['title'];
          isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _submitReview(int rating, String comment) async {
    if (userId == null) {
      _showLoginSnackBar();
      return;
    }

    if (comment.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please write a review comment',
            style: TextStyle(fontFamily: 'ADLaMDisplay'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text(
                'Posting review...',
                style: TextStyle(fontFamily: 'ADLaMDisplay'),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      await FirebaseFirestore.instance.collection('reviews').add({
        'productId': widget.product['id'],
        'userId': userId,
        'userName': userName ?? 'User',
        'rating': rating,
        'comment': comment.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Clear the loading snackbar
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Review posted successfully!',
                  style: TextStyle(fontFamily: 'ADLaMDisplay'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Review Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to post review. Please try again.',
                    style: TextStyle(fontFamily: 'ADLaMDisplay'),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Fixed Buy Now logic
  Future<void> _buyNow() async {
    if (userId == null) {
      _showLoginSnackBar();
      return;
    }

    // Create a temporary cart with this single product
    try {
      // Clear any existing cart first
      await DatabaseService.instance.clearCart(userId!);

      // Add this product to cart with selected quantity
      final success = await DatabaseService.instance.addToCart(
        userId: userId!,
        productId: widget.product['id'],
        quantity: quantity,
      );

      if (success && mounted) {
        // Navigate to checkout
        Navigator.pushNamed(context, '/checkout');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to proceed to checkout'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('Buy Now Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomAction(product),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(product),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(product),
                        const SizedBox(height: 24),
                        const Divider(),
                        _buildSectionTitle('About this product'),
                        const SizedBox(height: 8),
                        _buildDescription(product),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Select Quantity'),
                        const SizedBox(height: 12),
                        _buildQuantitySelector(),
                        const SizedBox(height: 32),
                        const Divider(),
                        _buildSectionTitle('Ratings & Reviews'),
                        const SizedBox(height: 16),
                        _buildReviewStream(),
                        const SizedBox(height: 12),
                        _buildAddReviewButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic> product) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.45,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product-${product['id']}',
          child: product['imageUrl'] != null && product['imageUrl'].isNotEmpty
              ? Image.network(product['imageUrl'], fit: BoxFit.cover)
              : Container(
                  color: AppColors.border,
                  child: const Icon(Icons.image, size: 80),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        categoryName!.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                    ),
                  Text(
                    product['name'] ?? 'Product',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IrishGrover',
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _buildPriceTag(product['price'] ?? 0),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceTag(dynamic price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Rs. $price',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'ADLaMDisplay',
        ),
      ),
    );
  }

  Widget _buildDescription(Map<String, dynamic> product) {
    return Text(
      product['description'] ?? 'No description available.',
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.5,
        fontFamily: 'ADLaMDisplay',
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => setState(() {
              if (quantity > 1) quantity--;
            }),
            icon: const Icon(
              Icons.remove_circle_outline,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          Text(
            '$quantity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'ADLaMDisplay',
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () => setState(() => quantity++),
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.accent,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('productId', isEqualTo: widget.product['id'])
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        if (snapshot.hasError) {
          // If error is due to missing index, show friendly message
          print('Review Stream Error: ${snapshot.error}');
          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: AppColors.accent, size: 40),
                SizedBox(height: 8),
                Text(
                  'Reviews are loading...',
                  style: TextStyle(
                    fontFamily: 'ADLaMDisplay',
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Please wait a moment for reviews to appear',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ADLaMDisplay',
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.rate_review,
                  color: AppColors.textSecondary,
                  size: 40,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No reviews yet",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'ADLaMDisplay',
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Be the first to review this product!",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'ADLaMDisplay',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Review count
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '${snapshot.data!.docs.length} Review${snapshot.data!.docs.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ADLaMDisplay',
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // Reviews list
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                return _buildReviewCard(data);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> data) {
    // Get timestamp if available
    final timestamp = data['timestamp'];
    String dateStr = 'Just now';

    if (timestamp != null) {
      try {
        final date = timestamp.toDate();
        final now = DateTime.now();
        final difference = now.difference(date);

        if (difference.inDays > 0) {
          dateStr =
              '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
        } else if (difference.inHours > 0) {
          dateStr =
              '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
        } else if (difference.inMinutes > 0) {
          dateStr =
              '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
        }
      } catch (e) {
        print('Error parsing timestamp: $e');
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: AppColors.accent.withOpacity(0.2),
                radius: 18,
                child: Text(
                  (data['userName'] ?? 'A')[0].toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['userName'] ?? 'Anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'ADLaMDisplay',
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'ADLaMDisplay',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Star rating
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 16,
                    color: i < (data['rating'] ?? 0)
                        ? Colors.orange
                        : Colors.grey[300],
                  ),
                ),
              ),
            ],
          ),
          if (data['comment'] != null &&
              data['comment'].toString().isNotEmpty) ...[
            SizedBox(height: 10),
            Text(
              data['comment'],
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontFamily: 'ADLaMDisplay',
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomAction(Map<String, dynamic> product) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'ADLaMDisplay',
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Rs. ${(product['price'] ?? 0) * quantity}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  fontFamily: 'IrishGrover',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: _addToCart,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: FittedBox(
                    child: Text(
                      'ADD TO CART',
                      style: TextStyle(
                        fontFamily: 'ADLaMDisplay',
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: _buyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const FittedBox(
                    child: Text(
                      'BUY NOW',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLoginSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please login to continue',
          style: TextStyle(fontFamily: 'ADLaMDisplay'),
        ),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'Login',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/login'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'IrishGrover',
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildAddReviewButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: _showReviewDialog,
        icon: const Icon(Icons.rate_review, size: 18, color: AppColors.accent),
        label: Text(
          "Write a Review",
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'ADLaMDisplay',
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  void _showReviewDialog() {
    if (userId == null) {
      _showLoginSnackBar();
      return;
    }

    int rating = 5;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Rate this product",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'IrishGrover',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    icon: Icon(
                      Icons.star,
                      color: i < rating ? Colors.orange : Colors.grey,
                      size: 32,
                    ),
                    onPressed: () => setModalState(() => rating = i + 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: "Write your experience...",
                  hintStyle: TextStyle(
                    fontFamily: 'ADLaMDisplay',
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _submitReview(rating, controller.text);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Post Review",
                    style: TextStyle(
                      fontFamily: 'ADLaMDisplay',
                      fontWeight: FontWeight.bold,
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

  Future<void> _addToCart() async {
    if (userId == null) {
      _showLoginSnackBar();
      return;
    }

    final success = await DatabaseService.instance.addToCart(
      userId: userId!,
      productId: widget.product['id'],
      quantity: quantity,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added to cart!',
            style: TextStyle(fontFamily: 'ADLaMDisplay'),
          ),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ),
      );
    }
  }
}
