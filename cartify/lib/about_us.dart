import 'package:flutter/material.dart';
import 'colors.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  final String pageId = 'ABOUT US';

  @override
  Widget build(BuildContext context) {
    // We wrap the whole body in a ValueListenableBuilder so it reacts to AppColors.notifyListeners()
    return ValueListenableBuilder<int>(
      valueListenable: AppColors.colorNotifier,
      builder: (context, _, __) {
        final accentColor = AppColors.getAccentForPage(pageId);
        final bgColor = AppColors.getBackgroundForPage(pageId);
        final textPrimary = AppColors.getTextPrimaryForPage(pageId);
        final textSecondary = AppColors.getTextSecondaryForPage(pageId);

        return Scaffold(
          backgroundColor: bgColor,
          body: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // 1. Enhanced Header with Gradient Overlay
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                stretch: true,
                backgroundColor: accentColor,
                leading: BackButton(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  centerTitle: true,
                  title: Text(
                    'CARTIFY',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accentColor,
                              accentColor.withBlue(
                                150,
                              ), // Slight variation for depth
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: -50,
                        top: -20,
                        child: Icon(
                          Icons.shopping_cart_rounded,
                          size: 200,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.auto_awesome,
                          size: 80,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fadeInWrapper(
                        delay: 0,
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'OUR STORY',
                                style: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Elevating your shopping experience.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40),

                      _fadeInWrapper(
                        delay: 200,
                        child: _buildModernCard(
                          'Our Vision',
                          'To become the world\'s most artistically driven e-commerce platform, where quality meets convenience.',
                          Icons.remove_red_eye_rounded,
                          accentColor,
                        ),
                      ),
                      SizedBox(height: 20),

                      _fadeInWrapper(
                        delay: 400,
                        child: _buildModernCard(
                          'Why Cartify?',
                          'We handpick every item in our inventory to ensure that your "cart" is always filled with excellence.',
                          Icons.verified_user_rounded,
                          accentColor,
                        ),
                      ),

                      SizedBox(height: 50),

                      // 3. Contact Section
                      _fadeInWrapper(
                        delay: 600,
                        child: _buildPremiumContactCard(accentColor),
                      ),

                      SizedBox(height: 40),
                      Center(
                        child: Text(
                          'VERSION 1.0.0',
                          style: TextStyle(
                            color: textSecondary.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernCard(
    String title,
    String desc,
    IconData icon,
    Color accent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardForPage(pageId),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.getBorderForPage(pageId),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimaryForPage(pageId),
            ),
          ),
          SizedBox(height: 10),
          Text(
            desc,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.getTextSecondaryForPage(pageId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumContactCard(Color accent) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.9), accent.withBlue(100)],
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 40),
          SizedBox(height: 15),
          Text(
            'Ready for your own app?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bring your ideas to life with custom development.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 25),
          MaterialButton(
            onPressed: () {},
            color: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mail_rounded, color: accent),
                SizedBox(width: 10),
                Text(
                  'UBdev2@gmail.com',
                  style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fadeInWrapper({required int delay, required Widget child}) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
