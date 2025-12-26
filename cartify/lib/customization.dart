import 'package:flutter/material.dart';
import 'colors.dart';
import 'customize_page.dart';

// ✅ UPDATED: Customization page showing all app pages
class CustomizationPage extends StatelessWidget {
  const CustomizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage('HOME'),
      appBar: AppBar(
        backgroundColor: AppColors.getAccentForPage('HOME'),
        title: Text(
          'Customization Panel',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'IrishGrover',
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildPageTile(
            context,
            icon: Icons.home,
            title: 'HOME',
            pageName: 'HOME',
          ),
          _buildPageTile(
            context,
            icon: Icons.shopping_bag,
            title: 'PRODUCTS',
            pageName: 'PRODUCTS',
          ),
          _buildPageTile(
            context,
            icon: Icons.person,
            title: 'PROFILE',
            pageName: 'PROFILE',
          ),
          _buildPageTile(
            context,
            icon: Icons.list,
            title: 'CATEGORIES',
            pageName: 'CATEGORIES',
          ),
          _buildPageTile(
            context,
            icon: Icons.shopping_cart,
            title: 'CART',
            pageName: 'CART',
          ),
          _buildPageTile(
            context,
            icon: Icons.smart_toy,
            title: 'CHATBOT',
            pageName: 'CHATBOT',
          ),
          _buildPageTile(
            context,
            icon: Icons.card_giftcard,
            title: 'REWARDS',
            pageName: 'REWARDS',
          ),
          _buildPageTile(
            context,
            icon: Icons.credit_card,
            title: 'CHECKOUT',
            pageName: 'CHECKOUT',
          ),
          _buildPageTile(
            context,
            icon: Icons.admin_panel_settings,
            title: 'ADMIN',
            pageName: 'ADMIN',
          ),
          _buildPageTile(
            context,
            icon: Icons.login,
            title: 'LOGIN / SIGNUP', // ✅ ADDED
            pageName: 'LOGIN',
          ),
          _buildPageTile(
            context,
            icon: Icons.info,
            title: 'ABOUT US',
            pageName: 'ABOUT US',
          ),
          _buildPageTile(
            context,
            icon: Icons.shield,
            title: 'PRIVACY POLICY',
            pageName: 'PRIVACY POLICY',
          ),
        ],
      ),
    );
  }

  Widget _buildPageTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String pageName,
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getCardForPage('HOME'),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderForPage('HOME')),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.getAccentForPage('HOME')),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimaryForPage('HOME'),
            fontFamily: 'ADLaMDisplay',
          ),
        ),
        trailing: Icon(Icons.chevron_right,
            color: AppColors.getTextSecondaryForPage('HOME')),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomizePage(pageName: pageName),
            ),
          );
        },
      ),
    );
  }
}