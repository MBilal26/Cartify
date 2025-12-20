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
                    'CARTIFY',
                    style: TextStyle(
                      fontFamily: 'IrishGrover',
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: AppColors.accent),
              title: Text(
                'Products',
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/products');
              },
            ),
            ExpansionTile(
              leading: Icon(Icons.checkroom, color: AppColors.accent),
              title: Text(
                'Categories',
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
              children: [
                ExpansionTile(
                  title: Text('Men', style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
                  children: [
                    ListTile(title: Text('Shirts', style: TextStyle(color: AppColors.textPrimary))),
                    ListTile(title: Text('Jeans', style: TextStyle(color: AppColors.textPrimary))),
                    ListTile(title: Text('Eyewear', style: TextStyle(color: AppColors.textPrimary))),
                    ListTile(title: Text('Accessories', style: TextStyle(color: AppColors.textPrimary))),
                    ListTile(title: Text('Footwear', style: TextStyle(color: AppColors.textPrimary))),
                  ],
                ),
                ExpansionTile(
                  title: Text('Women', style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
                  children: [
                    ListTile(title: Text('Dresses', style: TextStyle(color: AppColors.textPrimary))),
                    ListTile(title: Text('Jeans', style: TextStyle(color: AppColors.textPrimary))),
                    ListTile(title: Text('Eyewear', style: TextStyle(color: AppColors.textPrimary))),
                    ListTile(title: Text('Accessories', style: TextStyle(color: AppColors.textPrimary))),
                    ListTile(title: Text('Footwear', style: TextStyle(color: AppColors.textPrimary))),
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
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
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
              leading: Icon(Icons.admin_panel_settings, color: AppColors.accent),
              title: Text(
                'Admin Panel',
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin');
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.accent),
              title: Text(
                'About Us',
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: AppColors.accent),
              title: Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
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
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    Icon(Icons.search, color: AppColors.accent),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 180,
              child: PageView(
                children: const [
                  BannerImage(image: 'https://images.unsplash.com/photo-1521334884684-d80222895322'),
                  BannerImage(image: 'https://images.unsplash.com/photo-1445205170230-053b83016050'),
                  BannerImage(image: 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f'),
                ],
              ),
            ),
            SizedBox(height: 15),
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
                ),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  CategoryCard(title: 'Men', image: 'https://images.unsplash.com/photo-1521341057461-6eb5f40b07ab'),
                  CategoryCard(title: 'Women', image: 'https://images.unsplash.com/photo-1483985988355-763728e1935b'),
                  CategoryCard(title: 'Shoes', image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff'),
                  CategoryCard(title: 'Accessories', image: 'https://images.unsplash.com/photo-1519744792095-2f2205e87b6f'),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 150,
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1602810319428-019690571b5b'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.card,
              child: Text(
                "Hot Selling Products",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1520975916090-3105956dac38'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
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
              } else if (index == 4) {
                Navigator.pushNamed(context, '/admin');
              }
            },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Categories"),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
              BottomNavigationBarItem(icon: Icon(Icons.redeem), label: "Rewards"),
              BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: "Admin"),
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}