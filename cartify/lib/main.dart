import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_and_signup.dart';
import 'colors.dart';
import 'profile.dart';
import 'cart.dart';
import 'categories.dart';
import 'rewards.dart';
import 'checkout.dart';
import 'products_list.dart';
import 'product_detail.dart';
import 'admin_panel.dart';
import 'database_functions.dart';
import 'about_us.dart';
import 'privacy_policy.dart';
import 'carti_chatbot.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'customization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ WRAPPED with ValueListenableBuilder for global color updates
    return ValueListenableBuilder(
      valueListenable: AppColors.colorNotifier,
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => SplashScreen());
              case '/home':
                return PageRouteBuilder(
                  pageBuilder: (_, __, ___) => HomeScreen(),
                  transitionDuration: Duration(milliseconds: 900),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                );
              case '/login':
                return MaterialPageRoute(builder: (_) => LoginScreen());
              case '/signup':
                return MaterialPageRoute(builder: (_) => SignUpScreen());
              case '/profile':
                return MaterialPageRoute(builder: (_) => ProfilePage());
              case '/category':
                return MaterialPageRoute(builder: (_) => CategoriesPage());
              case '/products':
                return MaterialPageRoute(builder: (_) => ProductsListPage());
              case '/product_detail':
                final product = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product),
                );
              case '/cart':
                return MaterialPageRoute(builder: (_) => CartPage());
              case '/rewards':
                return MaterialPageRoute(builder: (_) => RewardsPage());
              case '/checkout':
                return MaterialPageRoute(builder: (_) => CheckoutPage());
              case '/admin':
                return MaterialPageRoute(builder: (_) => AdminPanelPage());
              case '/customization':
                return MaterialPageRoute(builder: (_) => CustomizationPage());
              case '/about_us':
                return MaterialPageRoute(builder: (_) => AboutUsPage());
              case '/privacy_policy':
                return MaterialPageRoute(builder: (_) => PrivacyPolicyPage());
              case '/carti':
                return MaterialPageRoute(builder: (_) => CartiChatbotPage());
              case '/category_products':
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (_) => CategoryProductsPage(
                    categoryId: args['categoryId'],
                    categoryName: args['categoryName'],
                    parentCategory: args['parentCategory'],
                  ),
                );
            }
            return null;
          },
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool isAdmin = false;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoadingProducts = true;

  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  // ✅ PAGE ID for color lookups
  final String pageId = 'HOME';

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadProducts();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkAdminStatus() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isAdmin = user?.email == 'cartifyshops@gmail.com';
    });
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoadingProducts = true;
    });

    final allProducts = await DatabaseService.instance.getAllProducts();

    setState(() {
      products = allProducts;
      filteredProducts = allProducts.take(6).toList();
      isLoadingProducts = false;
    });
  }

  Future<void> _loadCategories() async {
    final allCategories = await DatabaseService.instance.getCategories();
    setState(() {
      categories = allCategories;
    });
  }

  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = products.take(6).toList();
        isSearching = false;
      } else {
        isSearching = true;
        filteredProducts = products
            .where(
              (product) =>
          product['name'].toString().toLowerCase().contains(
            query.toLowerCase(),
          ) ||
              (product['description'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()),
        )
            .toList();
      }
    });
  }

  // ✅ UPDATED: Added optional categoryId parameter
  void _navigateToCategory(String categoryTitle, String parentCategory, {String? categoryId}) {
    Map<String, dynamic> category = {};

    // 1. If we have the ID directly (from Drawer), use it!
    if (categoryId != null) {
      category = {
        'id': categoryId,
        'title': categoryTitle,
        'parentCategory': parentCategory
      };
    }
    // 2. Otherwise try to find it in the list (for hardcoded cards)
    else {
      category = categories.firstWhere(
            (cat) =>
        cat['title'] == categoryTitle &&
            cat['parentCategory'] == parentCategory,
        orElse: () => {},
      );
    }

    if (category.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/category_products',
        arguments: {
          'categoryId': category['id'],
          'categoryName': categoryTitle,
          'parentCategory': parentCategory,
        },
      );
    } else {
      // If it fails, try reloading categories for next time
      _loadCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category not found. Please refresh.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('shirt')) return Icons.checkroom_outlined;
    if (name.contains('jean') || name.contains('pant')) return Icons.line_style_outlined;
    if (name.contains('dress')) return Icons.dry_cleaning_outlined;
    if (name.contains('eyewear') || name.contains('glass')) return Icons.visibility_outlined;
    if (name.contains('accessories')) return Icons.watch_outlined;
    if (name.contains('footwear') || name.contains('shoe')) return Icons.directions_walk_outlined;
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage(pageId), // ✅ UPDATED
      drawer: Drawer(
        backgroundColor: AppColors.getBackgroundForPage(pageId), // ✅ UPDATED
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/white-logo.png', height: 45),
                  const SizedBox(height: 10),
                  Text(
                    'Cartify',
                    style: TextStyle(
                      fontFamily: 'IrishGrover',
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ADMIN',
                        style: TextStyle(
                          fontFamily: 'ADLaMDisplay',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            ListTile(
              leading: Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
              ),
              title: Text(
                'Products',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                  color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/products');
              },
            ),

            ExpansionTile(
              leading: Icon(
                Icons.dashboard_customize_outlined,
                color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
              ),
              collapsedIconColor: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
              title: Text(
                'Categories',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                  color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                ),
              ),
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseService.instance.getCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return ListTile(
                        leading: Icon(Icons.info_outline, color: Colors.grey, size: 20),
                        title: Text(
                          'No categories yet',
                          style: TextStyle(
                            fontFamily: 'ADLaMDisplay',
                            fontSize: 14,
                            color: AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
                          ),
                        ),
                      );
                    }

                    final allCategories = snapshot.data!;
                    final parentCategories = allCategories
                        .where((cat) => cat['parentCategory'] == null)
                        .toList();

                    return Column(
                      children: parentCategories.map((parentCat) {
                        final parentTitle = parentCat['title'];
                        final subcategories = allCategories
                            .where((cat) => cat['parentCategory'] == parentTitle)
                            .toList();

                        return ExpansionTile(
                          leading: Icon(
                            parentTitle == 'Men'
                                ? Icons.man_outlined
                                : parentTitle == 'Women'
                                ? Icons.woman_outlined
                                : Icons.child_care, // Default/Kids icon
                            color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                          ),
                          collapsedIconColor: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                          title: Text(
                            parentTitle,
                            style: TextStyle(
                              fontFamily: 'ADLaMDisplay',
                              fontSize: 15,
                              color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                            ),
                          ),
                          children: subcategories.map((subCat) {
                            return _buildCategoryItem(
                              context,
                              subCat['title'],
                              _getCategoryIcon(subCat['title']),
                              parentTitle,
                              subCat['id'], // ✅ FIXED: Passing the ID
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),

            ListTile(
              leading: Icon(
                AppColors.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                  color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                ),
              ),
              trailing: Switch(
                value: AppColors.isDarkMode,
                onChanged: (value) {
                  setState(() {
                    AppColors.toggleTheme();
                  });
                },
                activeColor: AppColors.getAccentForPage(pageId), // ✅ UPDATED
              ),
            ),
            Divider(),

            ListTile(
              leading: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.getAccentForPage(pageId).withOpacity(0.1), // ✅ UPDATED
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.smart_toy, color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
              ),
              title: Text(
                'Cartify AI Assistant',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                  color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Your shopping helper',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 12,
                  color: AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/carti');
              },
            ),
            Divider(),

            ListTile(
              leading: Icon(Icons.storefront_outlined, color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
              title: Text(
                'About Us',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                  color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about_us');
              },
            ),

            ListTile(
              leading: Icon(Icons.gpp_maybe_outlined, color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
              title: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                  color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/privacy_policy');
              },
            ),
            Divider(),

            if (isAdmin)
              ListTile(
                leading: Icon(
                  Icons.admin_panel_settings_outlined,
                  color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                ),
                title: Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontFamily: 'ADLaMDisplay',
                    fontSize: 16,
                    color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
              ),

            if (isAdmin)
              ListTile(
                leading: Icon(
                  Icons.palette,
                  color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                ),
                title: Text(
                  'Customize',
                  style: TextStyle(
                    fontFamily: 'ADLaMDisplay',
                    fontSize: 16,
                    color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/customization');
                },
              ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: AppColors.getAccentForPage(pageId), // ✅ UPDATED
        // REMOVE the flexibleSpace gradient completely
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white), // CHANGED: White icon
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppColors.isDarkMode
                  ? 'assets/images/white-logo.png'
                  : 'assets/images/white-logo.png', // CHANGED: Always white logo
              height: 40,
            ),
            Text(
              ' CARTIFY',
              style: TextStyle(
                fontFamily: 'IrishGrover',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // CHANGED: White text
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.person_2_outlined, color: Colors.white), // CHANGED: White icon
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  Navigator.pushNamed(context, '/login');
                } else {
                  Navigator.pushNamed(context, '/profile');
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.getCardForPage(pageId), // ✅ UPDATED
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.getBorderForPage(pageId)), // ✅ UPDATED
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _searchProducts,
                        decoration: InputDecoration(
                          hintText: "Search products...",
                          hintStyle: TextStyle(
                            color: AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
                            fontFamily: 'ADLaMDisplay',
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: AppColors.getTextSecondaryForPage(pageId)), // ✅ UPDATED
                        onPressed: () {
                          _searchController.clear();
                          _searchProducts('');
                        },
                      ),
                    Icon(Icons.search, color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
                  ],
                ),
              ),
            ),

            if (!isSearching) ...[
              AutoBanner(),
              SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.getCardForPage(pageId), // ✅ UPDATED
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                    fontFamily: 'IrishGrover',
                  ),
                ),
              ),

              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  children: [
                    CategoryCard(
                      title: 'Dress',
                      image: 'assets/icons/categories_icon/dress_icon.png',
                      onTap: () => _navigateToCategory('Dresses', 'Women'),
                    ),
                    CategoryCard(
                      title: 'Pants',
                      image: 'assets/icons/categories_icon/pants_icon.png',
                      onTap: () => _navigateToCategory('Jeans', 'Men'),
                    ),
                    CategoryCard(
                      title: 'Eyewear',
                      image: 'assets/icons/categories_icon/eyewear_icon.png',
                      onTap: () => _navigateToCategory('Eyewear', 'Men'),
                    ),
                    CategoryCard(
                      title: 'Shoes',
                      image: 'assets/icons/categories_icon/shoes_icon.png',
                      onTap: () => _navigateToCategory('Footwear', 'Men'),
                    ),
                    CategoryCard(
                      title: 'Shirts',
                      image: 'assets/icons/categories_icon/shirts_icon.png',
                      onTap: () => _navigateToCategory('Shirts', 'Men'),
                    ),
                    CategoryCard(
                      title: 'Accessories',
                      image: 'assets/icons/categories_icon/accessories_icon.png',
                      onTap: () => _navigateToCategory('Accessories', 'Women'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),

              Container(
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/CARTIFY-banner.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.getCardForPage(pageId), // ✅ UPDATED
              child: Text(
                isSearching
                    ? "Search Results (${filteredProducts.length})"
                    : "Hot Selling Products",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                  fontFamily: 'IrishGrover',
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoadingProducts
                  ? Center(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    CircularProgressIndicator(color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
                    SizedBox(height: 16),
                    Text(
                      'Loading products...',
                      style: TextStyle(
                        color: AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                  ],
                ),
              )
                  : filteredProducts.isEmpty
                  ? Center(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Icon(Icons.search_off, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      isSearching
                          ? 'No products found'
                          : 'No products available',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                        fontFamily: 'IrishGrover',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      isSearching
                          ? 'Try different keywords'
                          : 'Products will appear here once added',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                    if (isSearching) ...[
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _searchController.clear();
                          _searchProducts('');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                        ),
                        child: Text(
                          'Clear Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'ADLaMDisplay',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredProducts.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.51,
                ),
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return _buildProductCard(product);
                },
              ),
            ),

            if (isSearching && filteredProducts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/products');
                    },
                    icon: Icon(Icons.grid_view, color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
                    label: Text(
                      'View All Products',
                      style: TextStyle(
                        color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                        fontFamily: 'ADLaMDisplay',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          child: BottomNavigationBar(
            backgroundColor: AppColors.getAccentBGForPage(pageId), // ✅ UPDATED
            currentIndex: _currentIndex,
            showUnselectedLabels: false,
            showSelectedLabels: true,
            selectedItemColor: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
            unselectedItemColor: AppColors.getTextSecondaryForPage(pageId), // ✅ UPDATED
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(fontFamily: 'ADLaMDisplay'),
            unselectedLabelStyle: TextStyle(fontFamily: 'ADLaMDisplay'),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              if (index == 0) {
                Navigator.pushNamed(context, '/home');
              } else if (index == 1) {
                Navigator.pushNamed(context, '/category');
              } else if (index == 2) {
                Navigator.pushNamed(context, '/cart');
              } else if (index == 3) {
                Navigator.pushNamed(context, '/rewards');
              }
            },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Categories"),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
              BottomNavigationBarItem(icon: Icon(Icons.redeem), label: "Rewards"),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ UPDATED: Added categoryId parameter here too
  Widget _buildCategoryItem(
      BuildContext context,
      String title,
      IconData icon,
      String parentCategory,
      String categoryId,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 40),
      leading: Icon(icon, color: AppColors.getAccentForPage(pageId), size: 20), // ✅ UPDATED
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'ADLaMDisplay',
          color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        // ✅ FIXED: Pass the specific ID so we don't rely on stale lookups
        _navigateToCategory(title, parentCategory, categoryId: categoryId);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    // ... existing product card code ...
    // (This part doesn't need changing but included for context if needed)
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product_detail',
          arguments: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardForPage(pageId), // ✅ UPDATED
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.getBorderForPage(pageId).withOpacity(0.2), // ✅ UPDATED
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: product['imageUrl'] != null &&
                          product['imageUrl'].isNotEmpty
                          ? Image.network(
                        product['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image,
                            color: Colors.grey, size: 40),
                      )
                          : const Icon(Icons.image,
                          size: 50, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Rs. ${product['price'] ?? 0}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] ?? 'Product',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                            fontFamily: 'ADLaMDisplay',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Freshly Stocked",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextSecondaryForPage(pageId).withOpacity(0.7), // ✅ UPDATED
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: OutlinedButton(
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Please login first")),
                                );
                                return;
                              }
                              final success =
                              await DatabaseService.instance.addToCart(
                                userId: user.uid,
                                productId: product['id'],
                                quantity: 1,
                              );
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Added to cart")),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.getAccentForPage(pageId), width: 1), // ✅ UPDATED
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              "Add to Cart",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                                fontFamily: 'ADLaMDisplay',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) return;
                              await DatabaseService.instance.addToCart(
                                userId: user.uid,
                                productId: product['id'],
                                quantity: 1,
                              );
                              Navigator.pushNamed(context, '/checkout');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              "Buy Now",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ADLaMDisplay',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 200,
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            image,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }
}

class AutoBanner extends StatefulWidget {
  const AutoBanner({super.key});

  @override
  State<AutoBanner> createState() => _AutoBannerState();
}

class _AutoBannerState extends State<AutoBanner> {
  late PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _images = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0, viewportFraction: 0.85);
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var path in _images) {
      precacheImage(AssetImage(path), context);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_controller.hasClients) {
        int nextPage = (_currentPage + 1) % _images.length;
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (v) => setState(() => _currentPage = v),
            itemCount: _images.length,
            itemBuilder: (context, i) {
              double scale = _currentPage == i ? 1.0 : 0.9;
              return AnimatedTransform(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                  child: PhysicalModel(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.3),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      _images[i],
                      fit: BoxFit.fill,
                      cacheWidth: 1000,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              );
            },
          ),
          _buildIndicators(),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_images.length, (index) {
          bool isActive = _currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
              boxShadow: isActive ? [BoxShadow(color: Colors.black26, blurRadius: 4)] : [],
            ),
          );
        }),
      ),
    );
  }
}

class AnimatedTransform extends StatelessWidget {
  final double scale;
  final Widget child;
  const AnimatedTransform({super.key, required this.scale, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      transform: Matrix4.identity()..scale(scale),
      transformAlignment: Alignment.center,
      child: child,
    );
  }
}