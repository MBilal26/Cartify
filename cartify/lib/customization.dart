import 'package:flutter/material.dart';
import 'colors.dart';

// ✅ NEW PAGE: Customization page for admin to modify app UI
class CustomizationPage extends StatelessWidget {
  const CustomizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.accent, // Teal green AppBar
        title: Text(
          'Customization',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'IrishGrover',
            fontSize: 22,
          ),
        ),
        centerTitle: true, // Centered title
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.palette,
                size: 100,
                color: AppColors.accent.withOpacity(0.5),
              ),
              SizedBox(height: 24),
              Text(
                'Customization Panel',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IrishGrover',
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'This section will allow you to customize app colors, texts, and layouts for each page individually.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontFamily: 'ADLaMDisplay',
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.accent),
                        SizedBox(width: 8),
                        Text(
                          'Coming Soon',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontFamily: 'ADLaMDisplay',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'â€¢ Customize page colors\n'
                          'â€¢ Edit text content\n'
                          'â€¢ Modify layouts\n'
                          'â€¢ Preview changes in real-time\n'
                          'â€¢ Save custom themes',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.6,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}