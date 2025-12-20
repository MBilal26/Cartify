import 'package:flutter/material.dart';
import 'colors.dart';
import 'database_functions.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.instance.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading categories: ${snapshot.error}'),
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
                  Text('No categories found'),
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
                  .where((cat) =>
                      cat['parentCategory'] == parentCategory['title'])
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

      // Floating action button to add categories (for testing)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(),
        backgroundColor: AppColors.accent,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Category',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
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
                        icon: Icon(Icons.add_circle_outline, color: AppColors.accent),
                        onPressed: () => _showAddCategoryDialog(parentCategory: title),
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
                      // Navigate to products page with category
                      Navigator.pushNamed(
                        context,
                        '/products',
                        arguments: '${title.toLowerCase()}_${subcategory['title'].toLowerCase()}',
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
    if (name.contains('jean') || name.contains('pant')) return Icons.shopping_bag;
    if (name.contains('dress')) return Icons.woman;
    if (name.contains('eyewear') || name.contains('glass')) return Icons.visibility;
    if (name.contains('accessories')) return Icons.watch;
    if (name.contains('footwear') || name.contains('shoe')) return Icons.directions_walk;
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
          title: Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Men, Shirts, etc.',
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
                    ),
                    Expanded(
                      child: Text('This is a parent category (e.g., Men, Women)'),
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
                          border: OutlineInputBorder(),
                        ),
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
              child: Text('Cancel'),
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
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}