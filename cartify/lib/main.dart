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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          case '/about_us':
            return MaterialPageRoute(builder: (_) => AboutUsPage());
          case '/privacy_policy':
            return MaterialPageRoute(builder: (_) => PrivacyPolicyPage());
        }
        return null;
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
  bool isLoadingProducts = true;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadProducts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        backgroundColor: AppColors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.accent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/white-logo.png', height: 45),
                  const SizedBox(height: 10),
                  Text(
                    'Cartify',
                    style: TextStyle(
                      fontFamily: 'ADLaMDisplay',
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
                color: AppColors.accent,
              ),
              title: Text(
                'Products',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                  color: AppColors.textPrimary,
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
                color: AppColors.accent,
              ),
              title: Text(
                'Categories',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              children: [
                ExpansionTile(
                  leading: Icon(Icons.man_outlined, color: AppColors.accent),
                  title: Text(
                    'Men',
                    style: TextStyle(
                      fontFamily: 'ADLaMDisplay',
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  children: [
                    _buildCategoryItem(
                      context,
                      'Shirts',
                      Icons.checkroom_outlined,
                    ),
                    _buildCategoryItem(
                      context,
                      'Jeans',
                      Icons.line_style_outlined,
                    ),
                    _buildCategoryItem(
                      context,
                      'Eyewear',
                      Icons.visibility_outlined,
                    ),
                    _buildCategoryItem(
                      context,
                      'Accessories',
                      Icons.watch_outlined,
                    ),
                    _buildCategoryItem(
                      context,
                      'Footwear',
                      Icons.directions_walk_outlined,
                    ),
                  ],
                ),
                ExpansionTile(
                  leading: Icon(Icons.woman_outlined, color: AppColors.accent),
                  title: Text(
                    'Women',
                    style: TextStyle(
                      fontFamily: 'ADLaMDisplay',
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  children: [
                    _buildCategoryItem(
                      context,
                      'Dresses',
                      Icons.dry_cleaning_outlined,
                    ),
                    _buildCategoryItem(
                      context,
                      'Jeans',
                      Icons.line_weight_outlined,
                    ),
                    _buildCategoryItem(
                      context,
                      'Eyewear',
                      Icons.face_retouching_natural_outlined,
                    ),
                    _buildCategoryItem(
                      context,
                      'Accessories',
                      Icons.shopping_basket_outlined,
                    ),
                    _buildCategoryItem(
                      context,
                      'Footwear',
                      Icons.height_outlined,
                    ),
                  ],
                ),
              ],
            ),

            ListTile(
              leading: Icon(
                AppColors.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.accent,
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: Switch(
                value: AppColors.isDarkMode,
                onChanged: (value) {
                  setState(() {
                    AppColors.toggleTheme();
                  });
                },
                activeColor: AppColors.accent,
              ),
            ),
            Divider(),

            ListTile(
              leading: Icon(Icons.storefront_outlined, color: AppColors.accent),
              title: Text(
                'About Us',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about_us');
              },
            ),

            ListTile(
              leading: Icon(Icons.gpp_maybe_outlined, color: AppColors.accent),
              title: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                  color: AppColors.textPrimary,
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
                  color: AppColors.accent,
                ),
                title: Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontFamily: 'ADLaMDisplay',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
              ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 2,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppGradients.splashBackground),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.secondary),
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
                  : 'assets/images/black-logo.png',
              height: 40,
            ),
            Text(
              ' CARTIFY',
              style: TextStyle(
                fontFamily: 'IrishGrover',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.person_2_outlined, color: AppColors.secondary),
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.border),
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
                            color: AppColors.textSecondary,
                            fontFamily: 'ADLaMDisplay',
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _searchProducts('');
                        },
                      ),
                    Icon(Icons.search, color: AppColors.accent),
                  ],
                ),
              ),
            ),

            // Banner Section (hide when searching)
            if (!isSearching) ...[
              AutoBanner(),
              SizedBox(height: 15),

              // Categories Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.card,
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontFamily: 'IrishGrover',
                  ),
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    CategoryCard(
                      title: 'Men',
                      image:
                          'https://images.unsplash.com/photo-1521341057461-6eb5f40b07ab',
                    ),
                    CategoryCard(
                      title: 'Women',
                      image:
                          'https://images.unsplash.com/photo-1483985988355-763728e1935b',
                    ),
                    CategoryCard(
                      title: 'Shoes',
                      image:
                          'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
                    ),
                    CategoryCard(
                      title: 'Accessories',
                      image:
                          'https://images.unsplash.com/photo-1519744792095-2f2205e87b6f',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),

              // Promotional Banner
              Container(
                height: 150,
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1602810319428-019690571b5b',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],

            // Products Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.card,
              child: Text(
                isSearching
                    ? "Search Results (${filteredProducts.length})"
                    : "Hot Selling Products",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
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
                          CircularProgressIndicator(color: AppColors.accent),
                          SizedBox(height: 16),
                          Text(
                            'Loading products...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
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
                              color: AppColors.textPrimary,
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
                                backgroundColor: AppColors.accent,
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
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
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
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
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
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.border,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    child:
                                        product['imageUrl'] != null &&
                                            product['imageUrl'].isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                            child: Image.network(
                                              product['imageUrl'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Center(
                                                      child: Icon(
                                                        Icons.image,
                                                        size: 50,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.image,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? 'Product',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                          fontFamily: 'ADLaMDisplay',
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Rs. ${product['price'] ?? 0}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          fontFamily: 'ADLaMDisplay',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Show all products button when searching
            if (isSearching && filteredProducts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/products');
                    },
                    icon: Icon(Icons.grid_view, color: AppColors.accent),
                    label: Text(
                      'View All Products',
                      style: TextStyle(
                        color: AppColors.accent,
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
          color: AppColors.accent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          child: BottomNavigationBar(
            backgroundColor: AppColors.accent,
            currentIndex: _currentIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
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
}

class BannerImage extends StatelessWidget {
  final String image;
  const BannerImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String image;
  const CategoryCard({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'ADLaMDisplay',
          ),
        ),
      ),
    );
  }
}

Widget _buildCategoryItem(BuildContext context, String title, IconData icon) {
  return ListTile(
    contentPadding: EdgeInsets.only(left: 40),
    leading: Icon(icon, color: AppColors.accent, size: 20),
    title: Text(
      title,
      style: TextStyle(
        fontFamily: 'ADLaMDisplay',
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
    ),
    onTap: () {
      Navigator.pop(context);
    },
  );
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
    _controller = PageController(initialPage: 0);

    // Start the auto-rotation
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_controller.hasClients) {
        _controller.animateToPage(
          _currentPage,
          duration: const Duration(
            milliseconds: 900,
          ), // Smoother, longer transition
          curve: Curves.easeInOutCubic, // A "natural" acceleration curve
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
    return Column(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                controller: _controller,
                onPageChanged: (v) => setState(() => _currentPage = v),
                itemCount: _images.length,
                // allowImplicitScrolling keeps the next image ready in the background
                allowImplicitScrolling: true,
                itemBuilder: (context, i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        _images[i],
                        fit: BoxFit.cover,
                        // gaplessPlayback prevents the flicker when images switch
                        gaplessPlayback: true,
                      ),
                    ),
                  );
                },
              ),

              // Connected Dots Indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_images.length, (index) {
                    bool isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8, // Active dot stretches
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          if (isActive)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
