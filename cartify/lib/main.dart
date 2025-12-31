import 'app_imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: "assets/.env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppColors.colorNotifier,
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return _smoothFade(const SplashScreen(), settings);
              case '/home':
                return _smoothFade(const HomeScreen(), settings);
              case '/login':
                return _smoothFade(const LoginScreen(), settings);
              case '/signup':
                return _smoothFade(const SignUpScreen(), settings);
              case '/profile':
                return _smoothFade(const ProfilePage(), settings);
              case '/category':
                return _smoothFade(const CategoriesPage(), settings);
              case '/products':
                return _smoothFade(const ProductsListPage(), settings);
              case '/product_detail':
                final product = settings.arguments as Map<String, dynamic>;
                return _smoothFade(
                  ProductDetailPage(product: product),
                  settings,
                );
              case '/cart':
                return _smoothFade(const CartPage(), settings);
              case '/rewards':
                return _smoothFade(const RewardsPage(), settings);
              case '/checkout':
                return _smoothFade(const CheckoutPage(), settings);
              case '/admin':
                return _smoothFade(const AdminPanelPage(), settings);
              case '/customization':
                return _smoothFade(const CustomizationPage(), settings);
              case '/about_us':
                return _smoothFade(AboutUsPage(), settings);
              case '/privacy_policy':
                return _smoothFade(PrivacyPolicyPage(), settings);
              case '/carti':
                return _smoothFade(const CartiChatbotPage(), settings);
              case '/category_products':
                final args = settings.arguments as Map<String, dynamic>;
                return _smoothFade(
                  CategoryProductsPage(
                    categoryId: args['categoryId'],
                    categoryName: args['categoryName'],
                    parentCategory: args['parentCategory'],
                  ),
                  settings,
                );
            }
            return null;
          },
        );
      },
    );
  }

  Route _smoothFade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings:
          settings, // Ensures arguments like product data are passed correctly
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(
        milliseconds: 500,
      ), // Sweet spot for "Smooth"
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut, // Smooth start and smooth end
          ),
          child: child,
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

  final String pageId = 'HOME';

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadProducts();
    _loadCategories();
    AppColors.colorNotifier.addListener(_updateTheme);
  }

  void _updateTheme() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppColors.colorNotifier.removeListener(_updateTheme);
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

  void _navigateToCategory(
    String categoryTitle,
    String parentCategory, {
    String? categoryId,
  }) {
    Map<String, dynamic> category = {};

    if (categoryId != null) {
      category = {
        'id': categoryId,
        'title': categoryTitle,
        'parentCategory': parentCategory,
      };
    } else {
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
    if (name.contains('jean') || name.contains('pant'))
      return Icons.line_style_outlined;
    if (name.contains('dress')) return Icons.dry_cleaning_outlined;
    if (name.contains('eyewear') || name.contains('glass'))
      return Icons.visibility_outlined;
    if (name.contains('accessories')) return Icons.watch_outlined;
    if (name.contains('footwear') || name.contains('shoe'))
      return Icons.directions_walk_outlined;
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage(pageId),
      drawer: Drawer(
        backgroundColor: AppColors.getBackgroundForPage(pageId),
        child: Column(
          children: [
            // 1. PREMIUM HEADER SECTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.getAccentForPage(pageId),
                    AppColors.getAccentForPage(pageId).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Image.asset('assets/images/white-logo.png', height: 45),
                  const SizedBox(height: 12),
                  const Text(
                    'CARTIFY',
                    style: TextStyle(
                      fontFamily: 'IrishGrover',
                      fontSize: 26,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (isAdmin)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: const Text(
                        'ADMINISTRATOR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. SCROLLABLE NAVIGATION LIST
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDrawerSectionLabel('SHOPPING'),

                  // Products Tile
                  _buildModernTile(
                    context,
                    title: 'Products',
                    icon: Icons.shopping_bag_outlined,
                    pageId: pageId,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/products');
                    },
                  ),

                  // CATEGORIES (Keep original FutureBuilder logic)
                  ExpansionTile(
                    leading: Icon(
                      Icons.grid_view_rounded,
                      color: AppColors.getAccentForPage(pageId),
                    ),
                    collapsedIconColor: AppColors.getTextPrimaryForPage(pageId),
                    title: Text(
                      'Categories',
                      style: TextStyle(
                        fontFamily: 'ADLaMDisplay',
                        fontSize: 16,
                        color: AppColors.getTextPrimaryForPage(pageId),
                      ),
                    ),
                    children: [
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: DatabaseService.instance.getCategories(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const ListTile(
                              title: Text(
                                'No categories yet',
                                style: TextStyle(fontSize: 12),
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
                                  .where(
                                    (cat) =>
                                        cat['parentCategory'] == parentTitle,
                                  )
                                  .toList();

                              return ExpansionTile(
                                leading: Icon(
                                  parentTitle == 'Men'
                                      ? Icons.man_outlined
                                      : parentTitle == 'Women'
                                      ? Icons.woman_outlined
                                      : Icons.child_care,
                                  color: AppColors.getAccentForPage(pageId),
                                ),
                                iconColor: AppColors.getTextPrimaryForPage(
                                  pageId,
                                ),
                                collapsedIconColor:
                                    AppColors.getTextPrimaryForPage(pageId),
                                title: Text(
                                  parentTitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'ADLaMDisplay',
                                    color: AppColors.getTextPrimaryForPage(
                                      pageId,
                                    ),
                                  ),
                                ),
                                children: subcategories.map((subCat) {
                                  return _buildCategoryItem(
                                    context,
                                    subCat['title'],
                                    _getCategoryIcon(subCat['title']),
                                    parentTitle,
                                    subCat['id'],
                                  );
                                }).toList(),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),

                  const Divider(height: 30),
                  _buildDrawerSectionLabel('ASSISTANT'),

                  // AI Assistant Feature Card
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.getAccentForPage(
                        pageId,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.getAccentForPage(pageId),
                        child: const Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Cartify AI Assistant',
                        style: TextStyle(
                          fontFamily: 'ADLaMDisplay',
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimaryForPage(pageId),
                        ),
                      ),
                      subtitle: const Text(
                        'Your shopping helper',
                        style: TextStyle(fontSize: 11),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/carti');
                      },
                    ),
                  ),

                  const Divider(height: 30),
                  _buildDrawerSectionLabel('SETTINGS & INFO'),

                  // Dark Mode Switch
                  ListTile(
                    leading: Icon(
                      AppColors.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.getAccentForPage(pageId),
                    ),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontFamily: 'ADLaMDisplay',
                        color: AppColors.getTextPrimaryForPage(pageId),
                      ),
                    ),
                    trailing: Switch.adaptive(
                      value: AppColors.isDarkMode,
                      activeColor: AppColors.getAccentForPage(pageId),
                      onChanged: (value) {
                        setState(() {
                          AppColors.toggleTheme();
                        });
                      },
                    ),
                  ),

                  _buildModernTile(
                    context,
                    title: 'About Us',
                    icon: Icons.storefront_outlined,
                    pageId: pageId,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/about_us');
                    },
                  ),

                  _buildModernTile(
                    context,
                    title: 'Privacy Policy',
                    icon: Icons.gpp_maybe_outlined,
                    pageId: pageId,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/privacy_policy');
                    },
                  ),

                  if (isAdmin) ...[
                    const Divider(height: 30),
                    _buildDrawerSectionLabel('ADMIN'),
                    _buildModernTile(
                      context,
                      title: 'Admin Panel',
                      icon: Icons.admin_panel_settings_outlined,
                      pageId: pageId,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/admin');
                      },
                    ),
                    _buildModernTile(
                      context,
                      title: 'Customize UI',
                      icon: Icons.palette_outlined,
                      pageId: pageId,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/customization');
                      },
                    ),
                  ],
                ],
              ),
            ),

            // FOOTER
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Version 1.0.2',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.getTextSecondaryForPage(
                    pageId,
                  ).withOpacity(0.5),
                  fontFamily: 'ADLaMDisplay',
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: AppColors.getAccentForPage(pageId),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.grid_view_rounded, color: Colors.white),
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
                  : 'assets/images/white-logo.png',
              height: 40,
            ),
            Text(
              ' CARTIFY',
              style: TextStyle(
                fontFamily: 'IrishGrover',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.person_3_rounded, color: Colors.white),
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
                  color: AppColors.getCardForPage(pageId),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.getBorderForPage(pageId)),
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
                            color: AppColors.getTextSecondaryForPage(pageId),
                            fontFamily: 'ADLaMDisplay',
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: AppColors.getTextPrimaryForPage(pageId),
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.getTextSecondaryForPage(pageId),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _searchProducts('');
                        },
                      ),
                    Icon(
                      Icons.search,
                      color: AppColors.getAccentForPage(pageId),
                    ),
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
                color: AppColors.getCardForPage(pageId),
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.getTextPrimaryForPage(pageId),
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
                      image:
                          'assets/icons/categories_icon/accessories_icon.png',
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
              color: AppColors.getCardForPage(pageId),
              child: Text(
                isSearching
                    ? "Search Results (${filteredProducts.length})"
                    : "Hot Selling Products",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.getTextPrimaryForPage(pageId),
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
                          CircularProgressIndicator(
                            color: AppColors.getAccentForPage(pageId),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading products...',
                            style: TextStyle(
                              color: AppColors.getTextSecondaryForPage(pageId),
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
                              color: AppColors.getTextPrimaryForPage(pageId),
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
                                backgroundColor: AppColors.getAccentForPage(
                                  pageId,
                                ),
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
                    icon: Icon(
                      Icons.grid_view,
                      color: AppColors.getAccentForPage(pageId),
                    ),
                    label: Text(
                      'View All Products',
                      style: TextStyle(
                        color: AppColors.getAccentForPage(pageId),
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
          color: AppColors.getAccentForPage(pageId),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          child: BottomNavigationBar(
            backgroundColor: AppColors.getAccentBGForPage(pageId),
            currentIndex: _currentIndex,
            showUnselectedLabels: false,
            showSelectedLabels: true,
            selectedItemColor: AppColors.getTextPrimaryForPage(pageId),
            unselectedItemColor: AppColors.getTextSecondaryForPage(pageId),
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
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view),
                label: "Categories",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: "Cart",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.redeem),
                label: "Rewards",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    IconData icon,
    String parentCategory,
    String categoryId,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 40),
      leading: Icon(icon, color: AppColors.getAccentForPage(pageId), size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'ADLaMDisplay',
          color: AppColors.getTextPrimaryForPage(pageId),
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        _navigateToCategory(title, parentCategory, categoryId: categoryId);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    // ... existing product card code ...
    // (This part doesn't need changing but included for context if needed)
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product_detail', arguments: product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardForPage(pageId),
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
                      color: AppColors.getBorderForPage(
                        pageId,
                      ).withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child:
                          product['imageUrl'] != null &&
                              product['imageUrl'].isNotEmpty
                          ? Image.network(
                              product['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                            )
                          : const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                            color: AppColors.getTextPrimaryForPage(pageId),
                            fontFamily: 'ADLaMDisplay',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Freshly Stocked",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextSecondaryForPage(
                              pageId,
                            ).withOpacity(0.7),
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
                              final success = await DatabaseService.instance
                                  .addToCart(
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
                                color: AppColors.getAccentForPage(pageId),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              "Add to Cart",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getAccentForPage(pageId),
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
                              backgroundColor: AppColors.getAccentForPage(
                                pageId,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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

  // In _AutoBannerState class
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _loadBanners();
    _controller = PageController(initialPage: 0, viewportFraction: 0.85);
    _startTimer();
  }

  Future<void> _loadBanners() async {
    final banners = await BannerService.instance.getBanners();
    setState(() {
      if (banners.isNotEmpty) {
        _images = banners;
      } else {
        // Default banners
        _images = [
          'assets/images/banner1.jpg',
          'assets/images/banner2.jpg',
          'assets/images/banner3.jpg',
        ];
      }
    });
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 6,
                  ),
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
              boxShadow: isActive
                  ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                  : [],
            ),
          );
        }),
      ),
    );
  }
}

Widget _buildDrawerSectionLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(left: 16, top: 10, bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    ),
  );
}

Widget _buildModernTile(
  BuildContext context, {
  required String title,
  required IconData icon,
  required VoidCallback onTap,
  required String pageId,
}) {
  return ListTile(
    visualDensity: VisualDensity.compact,
    leading: Icon(icon, color: AppColors.getAccentForPage(pageId), size: 22),
    title: Text(
      title,
      style: TextStyle(
        fontFamily: 'ADLaMDisplay',
        fontSize: 15,
        color: AppColors.getTextPrimaryForPage(pageId),
      ),
    ),
    trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
    onTap: onTap,
  );
}

class AnimatedTransform extends StatelessWidget {
  final double scale;
  final Widget child;
  const AnimatedTransform({
    super.key,
    required this.scale,
    required this.child,
  });

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
