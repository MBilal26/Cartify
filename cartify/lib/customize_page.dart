import 'package:flutter/material.dart';
import 'colors.dart';
import 'change_colors.dart';

// ✅ UPDATED: Customize page logic to hide options for ADMIN and LOGIN
class CustomizePage extends StatelessWidget {
  final String pageName;

  const CustomizePage({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage('HOME'),
      appBar: AppBar(
        backgroundColor: AppColors.getAccentForPage('HOME'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CUSTOMIZE',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'IrishGrover',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Page Name Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 32),
            color: AppColors.getBackgroundForPage('HOME'),
            child: Center(
              child: Text(
                pageName,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimaryForPage('HOME'),
                  fontFamily: 'IrishGrover',
                ),
              ),
            ),
          ),

          // Customization Options
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildCustomizationOption(
                  context,
                  icon: Icons.palette,
                  title: 'Change Colors',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangeColorsPage(pageName: pageName),
                      ),
                    );
                  },
                ),
                // ✅ HIDDEN for ADMIN and LOGIN pages
                if (pageName != 'ADMIN' && pageName != 'LOGIN') ...[
                  SizedBox(height: 12),
                  _buildCustomizationOption(
                    context,
                    icon: Icons.text_fields,
                    title: 'Change Text',
                    onTap: () {
                      _showComingSoonDialog(context, 'Change Text');
                    },
                  ),
                  SizedBox(height: 12),
                  _buildCustomizationOption(
                    context,
                    icon: Icons.format_align_left,
                    title: 'Change Alignment/Orientation',
                    onTap: () {
                      _showComingSoonDialog(
                          context, 'Change Alignment/Orientation');
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getCardForPage('HOME'),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderForPage('HOME')),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.getAccentForPage('HOME'), size: 24),
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
        onTap: onTap,
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.getCardForPage('HOME'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.construction,
                  color: AppColors.getAccentForPage('HOME')),
              SizedBox(width: 12),
              Text(
                'Coming Soon',
                style: TextStyle(
                  color: AppColors.getTextPrimaryForPage('HOME'),
                  fontFamily: 'IrishGrover',
                ),
              ),
            ],
          ),
          content: Text(
            '$feature feature is under development and will be available soon!',
            style: TextStyle(
              color: AppColors.getTextSecondaryForPage('HOME'),
              fontFamily: 'ADLaMDisplay',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.getAccentForPage('HOME'),
                  fontFamily: 'ADLaMDisplay',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}