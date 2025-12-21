import 'package:flutter/material.dart';
import 'colors.dart';
import 'database_functions.dart';

// ADMIN PANEL - Full working version with Gender & Category dropdown fixes
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

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    products = await DatabaseService.instance.getAllProducts();
    categories = await DatabaseService.instance.getCategories();

    setState(() => isLoading = false);
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
              color: Colors.white, fontFamily: 'IrishGrover', fontSize: 22),
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
            Icon(Icons.inventory_2_outlined,
                size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No products yet',
              style: TextStyle(
                  fontSize: 18, color: AppColors.textPrimary),
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
        itemBuilder: (context, index) =>
            _buildProductCard(products[index]),
      ),
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      color: AppColors.card,
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
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
            errorBuilder: (context, error, stackTrace) =>
                Container(width: 60, height: 60, color: AppColors.border, child: Icon(Icons.image, color: Colors.grey)),
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
              fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rs. ${product['price'] ?? 0}',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            if (product['description'] != null &&
                product['description'].isNotEmpty)
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
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showAddEditProductDialog(product: product),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(product),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditProductDialog({Map<String, dynamic>? product}) async {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final priceController =
    TextEditingController(text: product?['price']?.toString() ?? '');
    final descriptionController =
    TextEditingController(text: product?['description'] ?? '');
    final imageUrlController =
    TextEditingController(text: product?['imageUrl'] ?? '');

    String? selectedGender = product?['gender'];
    String? selectedCategoryId = product?['categoryId'];

    List<Map<String, dynamic>> availableCategories = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          if (selectedGender != null) {
            availableCategories = categories
                .where((cat) => cat['parentCategory'] == selectedGender)
                .toList();
          }

          return AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(
              isEdit ? 'Edit Product' : 'Add New Product',
              style: TextStyle(
                  color: AppColors.textPrimary, fontFamily: 'IrishGrover'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: 'Product Name *', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Price (Rs.) *', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                        labelText: 'Description', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: InputDecoration(
                        labelText: 'Gender *', border: OutlineInputBorder()),
                    items: ['Men', 'Women']
                        .map((g) => DropdownMenuItem<String>(
                      value: g,
                      child: Text(g),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedGender = value;
                        selectedCategoryId = null;
                      });
                    },
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                        labelText: 'Category *', border: OutlineInputBorder()),
                    items: selectedGender == null
                        ? [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('Select Gender First'),
                      )
                    ]
                        : availableCategories.isEmpty
                        ? [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                            'No categories for $selectedGender'),
                      )
                    ]
                        : availableCategories
                        .map((cat) => DropdownMenuItem<String>(
                      value: cat['id'].toString(),
                      child: Text(cat['title']),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: imageUrlController,
                    decoration: InputDecoration(
                        labelText: 'Image URL', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        selectedGender == null ||
                        selectedCategoryId == null) {
                      return;
                    }

                    Navigator.pop(context);

                    bool success = false;
                    if (isEdit) {
                      success = await DatabaseService.instance.updateProduct(
                        productId: product['id'], // FIXED: Removed '!'
                        name: nameController.text.trim(),
                        price: int.parse(priceController.text.trim()),
                        categoryId: selectedCategoryId!,
                        gender: selectedGender!,
                        imageUrl: imageUrlController.text.trim(),
                        description: descriptionController.text.trim(),
                      );
                    } else {
                      final productId =
                      await DatabaseService.instance.addProduct(
                        name: nameController.text.trim(),
                        price: int.parse(priceController.text.trim()),
                        categoryId: selectedCategoryId!,
                        gender: selectedGender!,
                        imageUrl: imageUrlController.text.trim(),
                        description: descriptionController.text.trim(),
                      );
                      success = productId != null;
                    }

                    if (success) _loadData();
                  },
                  child: Text(isEdit ? 'Update' : 'Add')),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> product) {
    DatabaseService.instance.deleteProduct(product['id']).then((_) {
      _loadData();
    });
  }
}