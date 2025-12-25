import 'package:flutter/material.dart';
import 'colors.dart';
import 'change_colors.dart';

// ✅ NEW FILE: Customize page for individual page customization
class CustomizePage extends StatelessWidget {
  final String pageName;

  const CustomizePage({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
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
            color: AppColors.background,
            child: Center(
              child: Text(
                pageName,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
                        builder: (context) => ChangeColorsPage(pageName: pageName),
                      ),
                    );
                  },
                ),
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
                    _showComingSoonDialog(context, 'Change Alignment/Orientation');
                  },
                ),
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent, size: 24),
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
        onTap: onTap,
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.construction, color: AppColors.accent),
              SizedBox(width: 12),
              Text(
                'Coming Soon',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'IrishGrover',
                ),
              ),
            ],
          ),
          content: Text(
            '$feature feature is under development and will be available soon!',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'ADLaMDisplay',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.accent,
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