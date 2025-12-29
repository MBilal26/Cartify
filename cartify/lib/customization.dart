import 'app_imports.dart';

class CustomizationPage extends StatelessWidget {
  const CustomizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppColors.getTextPrimaryForPage('HOME');

    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage('HOME'),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.accent,
        title: Text(
          'CUSTOMIZATION',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'IrishGrover',
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Design your App",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Select a page to modify its appearance",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondaryForPage('HOME'),
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                // --- FULL LIST RESTORED ---
                _buildModernCard(context, Icons.home, 'HOME', 'HOME'),
                _buildModernCard(
                  context,
                  Icons.shopping_bag,
                  'PRODUCTS',
                  'PRODUCTS',
                ),
                _buildModernCard(context, Icons.person, 'PROFILE', 'PROFILE'),
                _buildModernCard(
                  context,
                  Icons.list,
                  'CATEGORIES',
                  'CATEGORIES',
                ),
                _buildModernCard(context, Icons.shopping_cart, 'CART', 'CART'),
                _buildModernCard(
                  context,
                  Icons.smart_toy,
                  'CHATBOT',
                  'CHATBOT',
                ),
                _buildModernCard(
                  context,
                  Icons.card_giftcard,
                  'REWARDS',
                  'REWARDS',
                ),
                _buildModernCard(
                  context,
                  Icons.payments,
                  'CHECKOUT',
                  'CHECKOUT',
                ),
                _buildModernCard(
                  context,
                  Icons.admin_panel_settings,
                  'ADMIN',
                  'ADMIN',
                ),
                _buildModernCard(
                  context,
                  Icons.login,
                  'LOGIN / SIGNUP',
                  'LOGIN',
                ),
                _buildModernCard(context, Icons.info, 'ABOUT US', 'ABOUT US'),
                _buildModernCard(
                  context,
                  Icons.shield,
                  'PRIVACY POLICY',
                  'PRIVACY POLICY',
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildModernCard(
    BuildContext context,
    IconData icon,
    String title,
    String pageName,
  ) {
    final Color accentColor = AppColors.getAccentForPage('HOME');
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomizePage(pageName: pageName),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardForPage('HOME'),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.getBorderForPage('HOME').withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimaryForPage('HOME'),
                fontFamily: 'ADLaMDisplay',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
