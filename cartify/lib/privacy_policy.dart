import 'package:flutter/material.dart';
import 'colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Cartify',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Effective Date: December 2023',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            Divider(height: 40, color: AppColors.border),

            _policySection(
              '1. Data Collection',
              'Cartify collects information such as your name, email, and shipping address to fulfill your orders and improve our services.',
            ),

            _policySection(
              '2. Payment Safety',
              'All payments are handled through secure encrypted tunnels. Cartify does not store your full credit card information on our servers.',
            ),

            _policySection(
              '3. Your Choices',
              'You can update your account information or request data deletion at any time through the profile settings or by contacting support.',
            ),

            _policySection(
              '4. Security',
              'We use industry-standard protocols to protect your data, though no transmission over the internet is 100% secure.',
            ),

            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Contact us at support@cartify.com if you have any questions regarding your data privacy.',
                style: TextStyle(
                  color: AppColors.textaccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _policySection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textaccent, // Using your Teal Accent
            ),
          ),
          SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
