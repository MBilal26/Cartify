import 'app_imports.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final String pageId = 'PRIVACY POLICY';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppColors.colorNotifier,
      builder: (context, _, __) {
        final accentColor = AppColors.getAccentForPage(pageId);
        final bgColor = AppColors.getBackgroundForPage(pageId);
        final textPrimary = AppColors.getTextPrimaryForPage(pageId);
        final textSecondary = AppColors.getTextSecondaryForPage(pageId);
        final cardColor = AppColors.getCardForPage(pageId);
        final borderColor = AppColors.getBorderForPage(pageId);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              'Privacy Policy',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: accentColor,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Hero Section
                _buildHeader(accentColor, textPrimary, textSecondary),

                SizedBox(height: 30),

                // 2. Policy Sections (Card Based)
                _policyCard(
                  context,
                  title: '1. Data Collection',
                  body:
                      'Cartify collects information such as your name, email, and shipping address to fulfill your orders and improve our services.',
                  icon: Icons.analytics_outlined,
                  accent: accentColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textPrimary,
                  subTextColor: textSecondary,
                ),

                _policyCard(
                  context,
                  title: '2. Payment Safety',
                  body:
                      'All payments are handled through secure encrypted tunnels. Cartify does not store your full credit card information on our servers.',
                  icon: Icons.security_rounded,
                  accent: accentColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textPrimary,
                  subTextColor: textSecondary,
                ),

                _policyCard(
                  context,
                  title: '3. Your Choices',
                  body:
                      'You can update your account information or request data deletion at any time through the profile settings or by contacting support.',
                  icon: Icons.tune_rounded,
                  accent: accentColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textPrimary,
                  subTextColor: textSecondary,
                ),

                _policyCard(
                  context,
                  title: '4. Data Security',
                  body:
                      'We use industry-standard protocols to protect your data, though no transmission over the internet is 100% secure.',
                  icon: Icons.lock_outline_rounded,
                  accent: accentColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textPrimary,
                  subTextColor: textSecondary,
                ),

                SizedBox(height: 20),

                // 3. Modern Contact Footer
                _buildContactFooter(accentColor, cardColor, borderColor),

                SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Color accent, Color textP, Color textS) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 40,
              width: 5,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(width: 15),
            Text(
              'Privacy Policy for Cartify',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: textP,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Last Updated: December 2023',
            style: TextStyle(
              color: textS,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _policyCard(
    BuildContext context, {
    required String title,
    required String body,
    required IconData icon,
    required Color accent,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 16,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 70, right: 20, bottom: 20),
              child: Text(
                body,
                style: TextStyle(
                  color: subTextColor,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactFooter(Color accent, Color cardColor, Color border) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: accent),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Have questions regarding your data privacy?',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'support@cartify.com',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
