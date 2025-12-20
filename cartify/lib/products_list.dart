import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'database_functions.dart';

// NEW FILE: Products List Page with Filter functionality
// Shows all products in 2x2 grid with category filter
class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  String? userId;
  String selectedFilter = 'All'; // Default filter
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _loadData();
  }

  // Load products and categories from Firestore
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    // Load all products
    allProducts = await DatabaseService.instance.getAllProducts();

    // Load all categories
    categories = await DatabaseService.instance.getCategories();

    // Initially show all products
    filteredProducts = allProducts;

    setState(() {
      isLoading = false;
    });
  }

  // Filter products based on selected category
  void _filterProducts(String filter) {
    setState(() {
      selectedFilter = filter;

      if (filter == 'All') {
        // Show all products
        filteredProducts = allProducts;
      } else {
        // Find category ID for the selected filter
        final category = categories.firstWhere(
              (cat) => cat['title'] == filter,
          orElse: () => {},
        );

        if (category.isNotEmpty) {
          // Filter products by category ID
          filteredProducts = allProducts
              .where((product) => product['categoryId'] == category['id'])
              .toList();
        } else {
          filteredProducts = [];
        }
      }
    });
  }

  // Show filter options bottom sheet
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IrishGrover',
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(color: AppColors.border),
            SizedBox(height: 10),

            // "All" filter option
            _filterOption('All', Icons.grid_view),

            // Parent categories (Men, Women)
            ...categories
                .where((cat) => cat['parentCategory'] == null)
                .map((parentCat) {
              return Column(
                children: [
                  _filterOption(parentCat['title'], Icons.person),

                  // Subcategories under parent
                  ...categories
                      .where((cat) => cat['parentCategory'] == parentCat['title'])
                      .map((subCat) => Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: _filterOption(subCat['title'], Icons.category),
                  )),
                ],
              );
            }),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Filter option widget
  Widget _filterOption(String title, IconData icon) {
    final isSelected = selectedFilter == title;

    return InkWell(
      onTap: () {
        _filterProducts(title);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.accent),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Products',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'IrishGrover',
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),

        // Filter button in app bar
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.filter_list, color: AppColors.accent),
                onPressed: _showFilterOptions,
              ),
              // Badge showing active filter
              if (selectedFilter != 'All')
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 8),
        ],
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : Column(
        children: [
          // Filter chip showing current filter
          if (selectedFilter != 'All')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Chip(
                    backgroundColor: AppColors.accent.withOpacity(0.1),
                    label: Text(
                      selectedFilter,
                      style: TextStyle(color: AppColors.accent),
                    ),
                    deleteIcon: Icon(Icons.close, size: 18, color: AppColors.accent),
                    onDeleted: () => _filterProducts('All'),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${filteredProducts.length} products',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Products grid
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    selectedFilter != 'All'
                        ? 'Try selecting a different category'
                        : 'Products will appear here once added',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Product card widget
  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        // Navigate to product detail page
        Navigator.pushNamed(
          context,
          '/product_detail',
          arguments: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: product['imageUrl'] != null && product['imageUrl'].isNotEmpty
                    ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    product['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.image, size: 60, color: Colors.grey),
                      );
                    },
                  ),
                )
                    : Center(
                  child: Icon(Icons.image, size: 60, color: Colors.grey),
                ),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name (clickable)
                  Text(
                    product['name'] ?? 'Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Product Price
                  Text(
                    'Rs. ${product['price'] ?? 0}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        await _addToCart(product);
                      },
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add to cart functionality
  Future<void> _addToCart(Map<String, dynamic> product) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to add items to cart'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Login',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ),
      );
      return;
    }

    try {
      final success = await DatabaseService.instance.addToCart(
        userId: userId!,
        productId: product['id'],
        quantity: 1,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product['name']} added to cart'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}