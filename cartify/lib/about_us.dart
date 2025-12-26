import 'package:flutter/material.dart';
import 'colors.dart';

class AboutUsPage extends StatelessWidget {
  // ✅ CONSTANT: Page ID for Colors
  final String pageId = 'ABOUT US';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage(pageId), // ✅ UPDATED
      appBar: AppBar(
        title: Text('About Cartify', style: TextStyle(color: AppColors.getTextPrimaryForPage(pageId))), // ✅ UPDATED
        backgroundColor: AppColors.getAccentForPage(pageId), // ✅ UPDATED
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // Kept white for contrast on accent
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  // Placeholder for your logo
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.getAccentForPage(pageId).withOpacity(0.1), // ✅ UPDATED
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shopping_bag_outlined, size: 50, color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cartify',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
                    ),
                  ),
                  Text(
                    'Elevating your shopping experience.',
                    style: TextStyle(color: AppColors.getTextSecondaryForPage(pageId)), // ✅ UPDATED
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            _buildAboutCard(
                'Our Vision',
                'To become the world\'s most artistically driven e-commerce platform, where quality meets convenience.',
                Icons.visibility_outlined
            ),
            SizedBox(height: 20),
            _buildAboutCard(
                'Why Cartify?',
                'We handpick every item in our inventory to ensure that your "cart" is always filled with excellence.',
                Icons.auto_awesome_outlined
            ),
            SizedBox(height: 40),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.getTextSecondaryForPage(pageId), fontSize: 12), // ✅ UPDATED
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(String title, String description, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardForPage(pageId), // ✅ UPDATED
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.getBorderForPage(pageId)), // ✅ UPDATED
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.getAccentForPage(pageId)), // ✅ UPDATED
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.getTextPrimaryForPage(pageId)), // ✅ UPDATED
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: AppColors.getTextSecondaryForPage(pageId), height: 1.4), // ✅ UPDATED
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}