import 'package:flutter/material.dart';
import 'colors.dart';
import 'customize_page.dart';

// ✅ UPDATED: Customization page showing all app pages
class CustomizationPage extends StatelessWidget {
  const CustomizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
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
            icon: Icons.card_giftcard,
            title: 'REWARDS',
            pageName: 'REWARDS',
          ),
          _buildPageTile(
            context,
            icon: Icons.shopping_bag,
            title: 'CHECKOUT',
            pageName: 'CHECKOUT',
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'ADLaMDisplay',
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
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