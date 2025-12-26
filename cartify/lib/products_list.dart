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

  // NEW FILTER SYSTEM
  String selectedParentCategory = 'All'; // All, Men, Women, Kids
  List<String> selectedSubCategories = []; // Multiple sub-categories
  String sortBy = 'All'; // All, A->Z, Z->A, Low to High, High to Low

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String searchQuery = '';

  // ✅ CONSTANT: Page ID for Colors
  final String pageId = 'PRODUCTS';

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

  void _filterAndSortProducts() {
    setState(() {
      // Step 1: Filter by search query
      var tempProducts = allProducts.where((product) {
        final matchesSearch = searchQuery.isEmpty ||
            product['name'].toString().toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
        return matchesSearch;
      }).toList();

      // Step 2: Filter by parent category
      if (selectedParentCategory != 'All') {
        tempProducts = tempProducts.where((product) {
          return product['gender'] == selectedParentCategory;
        }).toList();
      }

      // Step 3: Filter by sub-categories (if any selected)
      if (selectedSubCategories.isNotEmpty) {
        tempProducts = tempProducts.where((product) {
          return selectedSubCategories.contains(product['categoryId']);
        }).toList();
      }

      // Step 4: Sort products
      if (sortBy == 'A->Z') {
        tempProducts.sort((a, b) =>
            (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
      } else if (sortBy == 'Z->A') {
        tempProducts.sort((a, b) =>
            (b['name'] ?? '').toString().compareTo((a['name'] ?? '').toString()));
      } else if (sortBy == 'Low to High') {
        tempProducts.sort(
                (a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
      } else if (sortBy == 'High to Low') {
        tempProducts.sort(
                (a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
      }

      filteredProducts = tempProducts;
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.getCardForPage(pageId), // ✅ UPDATED
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter & Sort',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IrishGrover',
                        color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              selectedParentCategory = 'All';
                              selectedSubCategories.clear();
                              sortBy = 'All';
                              searchQuery = '';
                            });
                          },
                          child: Text(
                            'Clear All',
                            style: TextStyle(
                              color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                              fontFamily: 'ADLaMDisplay',
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(color: AppColors.getBorderForPage(pageId)), // ✅ UPDATED

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),

                        // SORT BY SECTION
                        Text(
                          'Sort By',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IrishGrover',
                            color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                          ),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _sortChip('All', setModalState),
                            _sortChip('A->Z', setModalState),
                            _sortChip('Z->A', setModalState),
                            _sortChip('Low to High', setModalState),
                            _sortChip('High to Low', setModalState),
                          ],
                        ),

                        SizedBox(height: 24),

                        // PARENT CATEGORY SECTION
                        Text(
                          'Parent Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IrishGrover',
                            color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                          ),
                        ),
                        SizedBox(height: 12),

                        _parentCategoryOption(
                            'All', Icons.grid_view, setModalState),

                        ...categories
                            .where((cat) => cat['parentCategory'] == null)
                            .map((parentCat) {
                          return _parentCategoryOption(
                            parentCat['title'],
                            Icons.person,
                            setModalState,
                          );
                        }),

                        SizedBox(height: 24),

                        // SUB-CATEGORIES SECTION (Only if parent selected)
                        if (selectedParentCategory != 'All') ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sub-Categories',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IrishGrover',
                                  color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                                ),
                              ),
                              if (selectedSubCategories.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    setModalState(() {
                                      selectedSubCategories.clear();
                                    });
                                  },
                                  child: Text(
                                    'Select All',
                                    style: TextStyle(
                                      color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 12),

                          ...categories
                              .where((cat) =>
                          cat['parentCategory'] == selectedParentCategory)
                              .map((subCat) {
                            return _subCategoryOption(
                              subCat['title'],
                              subCat['id'],
                              Icons.category_outlined,
                              setModalState,
                            );
                          }),
                        ],

                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                // Apply Button
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.getCardForPage(pageId), // ✅ UPDATED
                    border: Border(top: BorderSide(color: AppColors.getBorderForPage(pageId))), // ✅ UPDATED
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _filterAndSortProducts();
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
      ),
    );
  }

  int _getFilteredCount() {
    var tempProducts = allProducts;

    if (selectedParentCategory != 'All') {
      tempProducts = tempProducts.where((product) {
        return product['gender'] == selectedParentCategory;
      }).toList();
    }

    if (selectedSubCategories.isNotEmpty) {
      tempProducts = tempProducts.where((product) {
        return selectedSubCategories.contains(product['categoryId']);
      }).toList();
    }

    return tempProducts.length;
  }

  Widget _sortChip(String sortOption, StateSetter setModalState) {
    final isSelected = sortBy == sortOption;
    return ChoiceChip(
      label: Text(
        sortOption,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'ADLaMDisplay',
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.getAccentForPage(pageId), // ✅ UPDATED
      backgroundColor: AppColors.getBackgroundForPage(pageId), // ✅ UPDATED
      side: BorderSide(
        color: isSelected
            ? AppColors.getAccentForPage(pageId) // ✅ UPDATED
            : AppColors.getBorderForPage(pageId), // ✅ UPDATED
        width: 1,
      ),
      onSelected: (selected) {
        setModalState(() {
          sortBy = sortOption;
        });
      },
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _parentCategoryOption(
      String title,
      IconData icon,
      StateSetter setModalState,
      ) {
    final isSelected = selectedParentCategory == title;

    return InkWell(
      onTap: () {
        setModalState(() {
          selectedParentCategory = title;
          selectedSubCategories
              .clear(); // Clear sub-categories when parent changes
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.getAccentForPage(pageId).withOpacity(0.1) // ✅ UPDATED
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.getAccentForPage(pageId) // ✅ UPDATED
                : AppColors.getBorderForPage(pageId), // ✅ UPDATED
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.getAccentForPage(pageId) // ✅ UPDATED
                  : AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.getAccentForPage(pageId) // ✅ UPDATED
                      : AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                  fontFamily: 'ADLaMDisplay',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.getAccentForPage(pageId), size: 20), // ✅ UPDATED
          ],
        ),
      ),
    );
  }

  Widget _subCategoryOption(
      String title,
      String categoryId,
      IconData icon,
      StateSetter setModalState,
      ) {
    final isSelected = selectedSubCategories.contains(categoryId);

    return InkWell(
      onTap: () {
        setModalState(() {
          if (isSelected) {
            selectedSubCategories.remove(categoryId);
          } else {
            selectedSubCategories.add(categoryId);
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.getAccentForPage(pageId).withOpacity(0.1) // ✅ UPDATED
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.getAccentForPage(pageId) // ✅ UPDATED
                : AppColors.getBorderForPage(pageId), // ✅ UPDATED
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected
                  ? AppColors.getAccentForPage(pageId) // ✅ UPDATED
                  : AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.getAccentForPage(pageId) // ✅ UPDATED
                      : AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                  fontFamily: 'ADLaMDisplay',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage(pageId), // ✅ UPDATED
      appBar: AppBar(
        backgroundColor: AppColors.getAccentForPage(pageId), // ✅ UPDATED
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Products',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'IrishGrover',
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.filter_list, color: Colors.white),
                onPressed: _showFilterOptions,
                tooltip: 'Filter',
              ),
              if (selectedParentCategory != 'All' ||
                  selectedSubCategories.isNotEmpty ||
                  sortBy != 'All')
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
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              style: TextStyle(
                color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                fontFamily: 'ADLaMDisplay',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(
                  color: AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search,
                    color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear,
                      color: AppColors.getTextSecondaryForPage(
                          pageId)), // ✅ UPDATED
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                    });
                    _filterAndSortProducts();
                  },
                )
                    : null,
                filled: true,
                fillColor: AppColors.getCardForPage(pageId), // ✅ UPDATED
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.getBorderForPage(pageId)), // ✅ UPDATED
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.getBorderForPage(pageId)), // ✅ UPDATED
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.getAccentForPage(pageId),
                      width: 2), // ✅ UPDATED
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
                _filterAndSortProducts();
              },
            ),
          ),

          // Active Filters Display
          if (selectedParentCategory != 'All' ||
              selectedSubCategories.isNotEmpty ||
              sortBy != 'All')
            Container(
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (sortBy != 'All')
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Chip(
                          backgroundColor: AppColors.getAccentForPage(pageId)
                              .withOpacity(0.1), // ✅ UPDATED
                          side: BorderSide(
                              color: AppColors.getAccentForPage(
                                  pageId)), // ✅ UPDATED
                          label: Text(
                            'Sort: $sortBy',
                            style: TextStyle(
                              color: AppColors.getAccentForPage(
                                  pageId), // ✅ UPDATED
                              fontFamily: 'ADLaMDisplay',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.getAccentForPage(
                                pageId), // ✅ UPDATED
                          ),
                          onDeleted: () {
                            setState(() {
                              sortBy = 'All';
                            });
                            _filterAndSortProducts();
                          },
                        ),
                      ),
                    if (selectedParentCategory != 'All')
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Chip(
                          backgroundColor: AppColors.getAccentForPage(pageId)
                              .withOpacity(0.1), // ✅ UPDATED
                          side: BorderSide(
                              color: AppColors.getAccentForPage(
                                  pageId)), // ✅ UPDATED
                          label: Text(
                            selectedParentCategory,
                            style: TextStyle(
                              color: AppColors.getAccentForPage(
                                  pageId), // ✅ UPDATED
                              fontFamily: 'ADLaMDisplay',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.getAccentForPage(
                                pageId), // ✅ UPDATED
                          ),
                          onDeleted: () {
                            setState(() {
                              selectedParentCategory = 'All';
                              selectedSubCategories.clear();
                            });
                            _filterAndSortProducts();
                          },
                        ),
                      ),
                    if (selectedSubCategories.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Chip(
                          backgroundColor: AppColors.getAccentForPage(pageId)
                              .withOpacity(0.1), // ✅ UPDATED
                          side: BorderSide(
                              color: AppColors.getAccentForPage(
                                  pageId)), // ✅ UPDATED
                          label: Text(
                            '${selectedSubCategories.length} sub-categories',
                            style: TextStyle(
                              color: AppColors.getAccentForPage(
                                  pageId), // ✅ UPDATED
                              fontFamily: 'ADLaMDisplay',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.getAccentForPage(
                                pageId), // ✅ UPDATED
                          ),
                          onDeleted: () {
                            setState(() {
                              selectedSubCategories.clear();
                            });
                            _filterAndSortProducts();
                          },
                        ),
                      ),
                    Text(
                      '${filteredProducts.length} products',
                      style: TextStyle(
                        color: AppColors.getTextSecondaryForPage(
                            pageId), // ✅ UPDATED
                        fontSize: 13,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Products Grid
          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(
                  color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
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
                        color: AppColors.getTextPrimaryForPage(
                            pageId), // ✅ UPDATED
                        fontFamily: 'IrishGrover',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      searchQuery.isNotEmpty
                          ? 'Try a different search term'
                          : 'Try adjusting your filters',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'ADLaMDisplay',
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedParentCategory = 'All';
                            selectedSubCategories.clear();
                            sortBy = 'All';
                            searchQuery = '';
                          });
                          _filterAndSortProducts();
                        },
                        icon: Icon(Icons.clear_all),
                        label: Text('Clear all filters'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                          AppColors.getAccentForPage(pageId), // ✅ UPDATED
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
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
          color: AppColors.getCardForPage(pageId), // ✅ UPDATED
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
              color: AppColors.getBorderForPage(pageId)), // ✅ UPDATED
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
              Container(
                height: 140,
                decoration: BoxDecoration(
                    color: AppColors.getBorderForPage(pageId)), // ✅ UPDATED
                child: product['imageUrl'] != null &&
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
              Expanded(
                child: Padding(
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
                          fontSize: 13,
                          color: AppColors.getTextPrimaryForPage(
                              pageId), // ✅ UPDATED
                          fontFamily: 'ADLaMDisplay',
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rs. ${product['price'] ?? 0}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'ADLaMDisplay',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.getAccentForPage(
                                pageId), // ✅ UPDATED
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