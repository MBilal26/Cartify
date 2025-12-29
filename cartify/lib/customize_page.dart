import 'package:flutter/material.dart';
import 'colors.dart';
import 'change_colors.dart';

class CustomizePage extends StatelessWidget {
  final String pageName;

  const CustomizePage({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    // Dynamically get colors based on which page we are customizing
    final Color primaryAccent = AppColors.getAccentForPage(pageName);
    final Color backgroundColor = AppColors.getBackgroundForPage(pageName);
    final Color textColor = AppColors.getTextPrimaryForPage(pageName);
    final Color cardColor = AppColors.getCardForPage(pageName);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Sleek Modern AppBar/Header
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: primaryAccent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                pageName,
                style: const TextStyle(
                  fontFamily: 'IrishGrover',
                  fontSize: 24,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Subtle gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryAccent,
                          primaryAccent.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  // Decorative icon in background
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.settings,
                      size: 150,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Customization Options List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionHeader("Visual Style", textColor),
                const SizedBox(height: 12),
                
                _buildOption(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Change Colors',
                  subtitle: 'Modify backgrounds and accents',
                  accent: primaryAccent,
                  cardColor: cardColor,
                  textColor: textColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeColorsPage(pageName: pageName),
                    ),
                  ),
                ),

                if (pageName == 'HOME') ...[
                  const SizedBox(height: 16),
                  _buildOption(
                    context,
                    icon: Icons.view_carousel_outlined,
                    title: 'Manage Banner',
                    subtitle: 'Update home screen promotions',
                    accent: primaryAccent,
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () => _showComingSoonDialog(context, 'Manage Banner', primaryAccent, cardColor),
                  ),
                ],

                if (pageName != 'ADMIN' && pageName != 'LOGIN') ...[
                  const SizedBox(height: 32),
                  _sectionHeader("Content & Layout", textColor),
                  const SizedBox(height: 12),
                  
                  _buildOption(
                    context,
                    icon: Icons.text_fields_rounded,
                    title: 'Change Text',
                    subtitle: 'Edit headers and descriptions',
                    accent: primaryAccent,
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () => _showComingSoonDialog(context, 'Change Text', primaryAccent, cardColor),
                  ),
                  const SizedBox(height: 16),
                  _buildOption(
                    context,
                    icon: Icons.grid_view_rounded,
                    title: 'Layout Orientation',
                    subtitle: 'Adjust alignment and spacing',
                    accent: primaryAccent,
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () => _showComingSoonDialog(context, 'Alignment', primaryAccent, cardColor),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, Color color) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: color.withOpacity(0.6),
        letterSpacing: 1.2,
        fontFamily: 'ADLaMDisplay',
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color accent,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Stylized Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: accent, size: 26),
                ),
                const SizedBox(width: 16),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontFamily: 'ADLaMDisplay',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: textColor.withOpacity(0.2), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature, Color accent, Color card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: accent.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.rocket_launch_rounded, color: accent, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              "Coming Soon!",
              style: TextStyle(fontFamily: 'IrishGrover', fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              "The $feature tool is currently under construction.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Got it"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}