import 'package:flutter/material.dart';
import 'colors.dart';
import 'database_functions.dart';

// SIMPLIFIED ADMIN PANEL - Uses image URLs instead of file upload
// No Firebase Storage required - perfect for free tier!
class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load products and categories
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    products = await DatabaseService.instance.getAllProducts();
    categories = await DatabaseService.instance.getCategories();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.accent,
        title: Text(
          'Admin Panel',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'IrishGrover',
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : products.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No products yet',
              style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first product using the + button',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product);
        },
      ),

      // Floating action button to add new product
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditProductDialog(),
        backgroundColor: AppColors.accent,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Product card with edit and delete options
  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      color: AppColors.card,
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product['imageUrl'] != null && product['imageUrl'].isNotEmpty
              ? Image.network(
            product['imageUrl'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: AppColors.border,
                child: Icon(Icons.image, color: Colors.grey),
              );
            },
          )
              : Container(
            width: 60,
            height: 60,
            color: AppColors.border,
            child: Icon(Icons.image, color: Colors.grey),
          ),
        ),
        title: Text(
          product['name'] ?? 'Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rs. ${product['price'] ?? 0}',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product['description'] != null && product['description'].isNotEmpty)
              Text(
                product['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.accent),
              onPressed: () => _showAddEditProductDialog(product: product),
            ),
            // Delete button
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _confirmDelete(product),
            ),
          ],
        ),
      ),
    );
  }

  // SIMPLIFIED Dialog - Just paste image URL (no file upload)
  void _showAddEditProductDialog({Map<String, dynamic>? product}) async {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final priceController = TextEditingController(
      text: product?['price']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: product?['description'] ?? '',
    );
    final imageUrlController = TextEditingController(
      text: product?['imageUrl'] ?? '',
    );
    String? selectedCategoryId = product?['categoryId'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            isEdit ? 'Edit Product' : 'Add New Product',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'IrishGrover',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                TextField(
                  controller: nameController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Product Name *',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),

                // Product Price
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Price (Rs.) *',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),

                // Product Description
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  dropdownColor: AppColors.card,
                  value: selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category *',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(),
                  ),
                  items: categories.isEmpty
                      ? [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'No categories - create one first',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    )
                  ]
                      : categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['id'],
                      child: Text(
                        cat['title'],
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategoryId = value;
                    });
                  },
                ),
                SizedBox(height: 16),

                // SIMPLIFIED: Just paste image URL
                TextField(
                  controller: imageUrlController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    hintText: 'Paste image URL here',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link, color: AppColors.accent),
                  ),
                ),
                SizedBox(height: 12),

                // Image preview
                if (imageUrlController.text.isNotEmpty)
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrlController.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: AppColors.error),
                                SizedBox(height: 4),
                                Text(
                                  'Invalid URL',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                SizedBox(height: 8),

                // Helper text
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.accent, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Upload image to ImgBB.com or Imgur.com and paste URL here',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              onPressed: () async {
                // Validate inputs
                if (nameController.text.trim().isEmpty ||
                    priceController.text.trim().isEmpty ||
                    selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Close dialog
                Navigator.pop(context);

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.accent),
                            SizedBox(height: 16),
                            Text('Saving...', style: TextStyle(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                // Add or update product (SIMPLIFIED - just use the URL)
                bool success = false;
                if (isEdit) {
                  success = await DatabaseService.instance.updateProduct(
                    productId: product['id'],
                    name: nameController.text.trim(),
                    price: int.parse(priceController.text.trim()),
                    categoryId: selectedCategoryId!,
                    imageUrl: imageUrlController.text.trim(),
                    description: descriptionController.text.trim(),
                  );
                } else {
                  final productId = await DatabaseService.instance.addProduct(
                    name: nameController.text.trim(),
                    price: int.parse(priceController.text.trim()),
                    categoryId: selectedCategoryId!,
                    imageUrl: imageUrlController.text.trim(),
                    description: descriptionController.text.trim(),
                  );
                  success = productId != null;
                }

                Navigator.pop(context); // Close loading dialog

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit ? 'Product updated successfully' : 'Product added successfully',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadData(); // Refresh list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save product'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: Text(
                isEdit ? 'Update' : 'Add',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Confirm delete dialog (SIMPLIFIED - no image deletion needed)
  void _confirmDelete(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete Product', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${product['name']}"? This action cannot be undone.',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.accent),
                          SizedBox(height: 16),
                          Text('Deleting...', style: TextStyle(color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              // Delete product from Firestore (no image deletion needed)
              final success = await DatabaseService.instance.deleteProduct(product['id']);

              Navigator.pop(context); // Close loading dialog

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadData(); // Refresh list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete product'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}