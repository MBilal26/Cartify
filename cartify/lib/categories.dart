import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'database_functions.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool isAdmin = false;
  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.accent,//FIXED APPBAR
        title: Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,//FIXED
            fontFamily: 'IrishGrover',
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),//FIXED
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.instance.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading categories: ${snapshot.error}',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            );
          }

          final allCategories = snapshot.data ?? [];

          // Separate parent categories
          final parentCategories = allCategories
              .where((cat) => cat['parentCategory'] == null)
              .toList();

          if (parentCategories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No categories found',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add categories using the + button',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: parentCategories.length,
            itemBuilder: (context, index) {
              final parentCategory = parentCategories[index];

              // Get subcategories for this parent
              final subcategories = allCategories
                  .where(
                    (cat) => cat['parentCategory'] == parentCategory['title'],
                  )
                  .toList();

              return _categorySection(
                context,
                title: parentCategory['title'],
                categoryId: parentCategory['id'],
                subcategories: subcategories,
              );
            },
          );
        },
      ),

      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddCategoryDialog(),
              backgroundColor: AppColors.accent,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Category',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  void _checkAdminStatus() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isAdmin = user?.email == 'cartifyshops@gmail.com';
    });
  }

  // CATEGORY SECTION
  Widget _categorySection(
    BuildContext context, {
    required String title,
    required String categoryId,
    required List<Map<String, dynamic>> subcategories,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'IrishGrover',
          ),
        ),
        const SizedBox(height: 10),

        subcategories.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No subcategories yet. Click + to add.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: AppColors.accent,
                        ),
                        onPressed: () =>
                            _showAddCategoryDialog(parentCategory: title),
                      ),
                    ],
                  ),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subcategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final subcategory = subcategories[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Navigate to products page filtered by this category
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryProductsPage(
                            categoryId: subcategory['id'],
                            categoryName: subcategory['title'],
                            parentCategory: title,
                          ),
                        ),
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
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getCategoryIcon(subcategory['title']),
                            size: 40,
                            color: AppColors.accent,
                          ),
                          SizedBox(height: 8),
                          Text(
                            subcategory['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

        const SizedBox(height: 20),
      ],
    );
  }

  // Get icon based on category name
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('shirt')) return Icons.checkroom;
    if (name.contains('jean') || name.contains('pant'))
      return Icons.shopping_bag;
    if (name.contains('dress')) return Icons.woman;
    if (name.contains('eyewear') || name.contains('glass'))
      return Icons.visibility;
    if (name.contains('accessories')) return Icons.watch;
    if (name.contains('footwear') || name.contains('shoe'))
      return Icons.directions_walk;
    return Icons.category;
  }

  // Add category dialog
  void _showAddCategoryDialog({String? parentCategory}) async {
    final titleController = TextEditingController();
    bool isParent = parentCategory == null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Add Category',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Men, Shirts, etc.',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              SizedBox(height: 16),
              if (parentCategory == null) ...[
                Row(
                  children: [
                    Checkbox(
                      value: isParent,
                      onChanged: (value) {
                        setDialogState(() {
                          isParent = value ?? true;
                        });
                      },
                      activeColor: AppColors.accent,
                    ),
                    Expanded(
                      child: Text(
                        'This is a parent category (e.g., Men, Women)',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                if (!isParent) ...[
                  SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: DatabaseService.instance.getCategories(),
                    builder: (context, snapshot) {
                      final categories = snapshot.data ?? [];
                      final parents = categories
                          .where((cat) => cat['parentCategory'] == null)
                          .toList();

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Parent Category',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                          border: OutlineInputBorder(),
                        ),
                        dropdownColor: AppColors.card,
                        style: TextStyle(color: AppColors.textPrimary),
                        items: parents.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat['title'],
                            child: Text(cat['title']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          parentCategory = value;
                        },
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final categoryId = await DatabaseService.instance.addCategory(
                    title: titleController.text.trim(),
                    parentCategory: isParent ? null : parentCategory,
                  );

                  Navigator.pop(context);

                  if (categoryId != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category added successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    setState(() {}); // Refresh the page
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add category'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a category name'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// NEW PAGE: Category Products Page
// Shows all products in a specific category
class CategoryProductsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String parentCategory;

  const CategoryProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.parentCategory,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });

    final allProducts = await DatabaseService.instance.getAllProducts();

    // Filter products by category ID
    products = allProducts
        .where((product) => product['categoryId'] == widget.categoryId)
        .toList();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Column(
          children: [
            Text(
              widget.categoryName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'IrishGrover',
                fontSize: 20,
              ),
            ),
            Text(
              widget.parentCategory,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : products.isEmpty
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
                    'No products in this category',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Products will appear here once added',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product);
              },
            ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product_detail', arguments: product);
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
                child:
                    product['imageUrl'] != null &&
                        product['imageUrl'].isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          product['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image,
                                size: 60,
                                color: Colors.grey,
                              ),
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
                  Text(
                    'Rs. ${product['price'] ?? 0}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                        style: TextStyle(fontSize: 12, color: Colors.white),
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

  Future<void> _addToCart(Map<String, dynamic> product) async {
    // Import firebase_auth at the top of this file to use this
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
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
        userId: user.uid,
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
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}
