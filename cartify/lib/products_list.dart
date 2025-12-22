import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'database_functions.dart';

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  String? userId;
  String selectedFilter = 'All';
  String selectedGender = 'All';
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    allProducts = await DatabaseService.instance.getAllProducts();
    categories = await DatabaseService.instance.getCategories();
    filteredProducts = allProducts;

    setState(() {
      isLoading = false;
    });
  }

  void _filterProducts() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        final matchesSearch =
            searchQuery.isEmpty ||
            product['name'].toString().toLowerCase().contains(
              searchQuery.toLowerCase(),
            );

        final matchesGender =
            selectedGender == 'All' || product['gender'] == selectedGender;

        bool matchesCategory = selectedFilter == 'All';
        if (!matchesCategory) {
          final category = categories.firstWhere(
            (cat) => cat['title'] == selectedFilter,
            orElse: () => {},
          );
          if (category.isNotEmpty) {
            matchesCategory = product['categoryId'] == category['id'];
          }
        }

        return matchesSearch && matchesGender && matchesCategory;
      }).toList();
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IrishGrover',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'All';
                            selectedGender = 'All';
                            searchQuery = '';
                          });
                          _filterProducts();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontFamily: 'ADLaMDisplay',
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(color: AppColors.border),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),

                      Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IrishGrover',
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _genderChip('All'),
                          _genderChip('Men'),
                          _genderChip('Women'),
                        ],
                      ),

                      SizedBox(height: 24),

                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IrishGrover',
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12),

                      _categoryOption('All', Icons.grid_view),

                      ...categories
                          .where((cat) => cat['parentCategory'] == null)
                          .map((parentCat) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                _categoryOption(
                                  parentCat['title'],
                                  Icons.person,
                                ),

                                ...categories
                                    .where(
                                      (cat) =>
                                          cat['parentCategory'] ==
                                          parentCat['title'],
                                    )
                                    .map(
                                      (subCat) => Padding(
                                        padding: EdgeInsets.only(left: 24),
                                        child: _categoryOption(
                                          subCat['title'],
                                          Icons.category_outlined,
                                        ),
                                      ),
                                    ),
                              ],
                            );
                          }),

                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _filterProducts();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Apply Filters (${_getFilteredCount()} products)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ADLaMDisplay',
                      ),
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

  int _getFilteredCount() {
    return allProducts.where((product) {
      final matchesGender =
          selectedGender == 'All' || product['gender'] == selectedGender;

      bool matchesCategory = selectedFilter == 'All';
      if (!matchesCategory) {
        final category = categories.firstWhere(
          (cat) => cat['title'] == selectedFilter,
          orElse: () => {},
        );
        if (category.isNotEmpty) {
          matchesCategory = product['categoryId'] == category['id'];
        }
      }

      return matchesGender && matchesCategory;
    }).length;
  }

  Widget _genderChip(String gender) {
    final isSelected = selectedGender == gender;
    return ChoiceChip(
      label: Text(
        gender,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'ADLaMDisplay',
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.accent,
      backgroundColor: AppColors.background,
      side: BorderSide(
        color: isSelected ? AppColors.accent : AppColors.border,
        width: 1,
      ),
      onSelected: (selected) {
        setState(() {
          selectedGender = gender;
        });
      },
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _categoryOption(String title, IconData icon) {
    final isSelected = selectedFilter == title;

    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.accent : AppColors.textPrimary,
                  fontFamily: 'ADLaMDisplay',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.accent, size: 20),
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
        elevation: 0,
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
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.filter_list, color: AppColors.accent),
                onPressed: _showFilterOptions,
                tooltip: 'Filter',
              ),
              if (selectedFilter != 'All' || selectedGender != 'All')
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'ADLaMDisplay',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.accent),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                          });
                          _filterProducts();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accent, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _filterProducts();
              },
            ),
          ),

          if (selectedFilter != 'All' || selectedGender != 'All')
            Container(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (selectedGender != 'All')
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Chip(
                          backgroundColor: AppColors.accent.withOpacity(0.1),
                          side: BorderSide(color: AppColors.accent),
                          label: Text(
                            selectedGender,
                            style: TextStyle(
                              color: AppColors.accent,
                              fontFamily: 'ADLaMDisplay',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          onDeleted: () {
                            setState(() {
                              selectedGender = 'All';
                            });
                            _filterProducts();
                          },
                        ),
                      ),
                    if (selectedFilter != 'All')
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Chip(
                          backgroundColor: AppColors.accent.withOpacity(0.1),
                          side: BorderSide(color: AppColors.accent),
                          label: Text(
                            selectedFilter,
                            style: TextStyle(
                              color: AppColors.accent,
                              fontFamily: 'ADLaMDisplay',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          onDeleted: () {
                            setState(() {
                              selectedFilter = 'All';
                            });
                            _filterProducts();
                          },
                        ),
                      ),
                    Text(
                      '${filteredProducts.length} products',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : filteredProducts.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(32),
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
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontFamily: 'IrishGrover',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            searchQuery.isNotEmpty
                                ? 'Try a different search term'
                                : (selectedFilter != 'All' ||
                                      selectedGender != 'All')
                                ? 'Try adjusting your filters'
                                : 'Products will appear here once added',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'ADLaMDisplay',
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (selectedFilter != 'All' ||
                              selectedGender != 'All' ||
                              searchQuery.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    selectedFilter = 'All';
                                    selectedGender = 'All';
                                    searchQuery = '';
                                  });
                                  _filterProducts();
                                },
                                icon: Icon(Icons.clear_all),
                                label: Text('Clear all filters'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppColors.accent,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.58,
                          ),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
                  ),
          ),
        ],
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
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image - Fixed height
              Container(
                height: 140,
                decoration: BoxDecoration(color: AppColors.border),
                child:
                    product['imageUrl'] != null &&
                        product['imageUrl'].isNotEmpty
                    ? Image.network(
                        product['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
              ),

              // Product Details - Fixed layout
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name - Fixed 2 lines
                      Text(
                        product['name'] ?? 'Product',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontFamily: 'ADLaMDisplay',
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4),

                      // Product Price
                      Text(
                        'Rs. ${product['price'] ?? 0}',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'ADLaMDisplay',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Spacer(),

                      // Add to Cart Button
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            await _addToCart(product);
                          },
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ADLaMDisplay',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please login to add items to cart',
            style: TextStyle(fontFamily: 'ADLaMDisplay'),
          ),
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
            content: Text(
              '${product['name']} added to cart',
              style: TextStyle(fontFamily: 'ADLaMDisplay'),
            ),
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
            content: Text(
              'Failed to add to cart',
              style: TextStyle(fontFamily: 'ADLaMDisplay'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
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
}
