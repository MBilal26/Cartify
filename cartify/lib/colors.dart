import 'package:flutter/material.dart';

// ============================================================================
// PAGE-SPECIFIC COLOR SYSTEM
// ============================================================================

class PageColors {
  Color? accent;
  Color? background;
  Color? textPrimary;
  Color? textSecondary;
  Color? card;
  Color? border;
  Color? accentBG;
  Color? gradientStart;
  Color? gradientEnd;

  PageColors({
    this.accent,
    this.background,
    this.textPrimary,
    this.textSecondary,
    this.card,
    this.border,
    this.accentBG,
    this.gradientStart,
    this.gradientEnd,
  });

  void reset() {
    accent = null;
    background = null;
    textPrimary = null;
    textSecondary = null;
    card = null;
    border = null;
    accentBG = null;
    gradientStart = null;
    gradientEnd = null;
  }
}

class AppGradients {
  static LinearGradient splashBackgroundForPage(String pageName) {
    final pageColors = AppColors.getPageColors(pageName);

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: AppColors.isDarkMode
          ? [
        pageColors.gradientStart ?? Color(0xFF008080),
        pageColors.gradientEnd ?? Color.fromARGB(255, 28, 28, 28)
      ]
          : [
        pageColors.gradientStart ?? Color(0xFF008080),
        pageColors.gradientEnd ?? Color.fromARGB(255, 255, 255, 255)
      ],
    );
  }

  static LinearGradient get splashBackground => splashBackgroundForPage('HOME');
}

class AppColors {
  // ✅ This notifier acts as the "Radio Station" telling the app to update
  static final ValueNotifier<int> colorNotifier = ValueNotifier(0);

  // ✅ Call this function whenever you change a color to trigger a rebuild
  static void notifyListeners() {
    colorNotifier.value++;
  }

  static bool isDarkMode = false;

  // Page-specific color storage
  static Map<String, PageColors> _pageColors = {
    'HOME': PageColors(),
    'PROFILE': PageColors(),
    'CATEGORIES': PageColors(),
    'CART': PageColors(),
    'REWARDS': PageColors(),
    'CHECKOUT': PageColors(),
    'PRODUCTS': PageColors(),
    'CHATBOT': PageColors(),
    'ADMIN': PageColors(),
    'LOGIN': PageColors(), // ✅ ADDED: Controls Login, Signup, and Splash
    'ABOUT US': PageColors(),
    'PRIVACY POLICY': PageColors(),
  };

  // Current active page for color customization
  static String _currentPage = 'HOME';

  static void setCurrentPage(String pageName) {
    _currentPage = pageName;
  }

  static String getCurrentPage() {
    return _currentPage;
  }

  static PageColors getPageColors(String pageName) {
    return _pageColors[pageName] ?? PageColors();
  }

  static void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // Reset specific page colors
  static void resetPageColors(String pageName) {
    _pageColors[pageName]?.reset();
    notifyListeners();
  }

  // Reset all page colors
  static void resetToDefaults() {
    _pageColors.forEach((key, value) {
      value.reset();
    });
    notifyListeners();
  }

  // Get color for specific page (with fallback to defaults)
  static Color getAccentForPage(String pageName) {
    return _pageColors[pageName]?.accent ?? Color(0xFF008080);
  }

  static Color getBackgroundForPage(String pageName) {
    return _pageColors[pageName]?.background ??
        (isDarkMode ? Color.fromARGB(255, 28, 28, 28) : Colors.white);
  }

  static Color getTextPrimaryForPage(String pageName) {
    return _pageColors[pageName]?.textPrimary ??
        (isDarkMode ? Colors.white : Colors.black);
  }

  static Color getTextSecondaryForPage(String pageName) {
    return _pageColors[pageName]?.textSecondary ??
        (isDarkMode
            ? Color.fromARGB(255, 180, 180, 180)
            : Color.fromARGB(255, 100, 100, 100));
  }

  static Color getCardForPage(String pageName) {
    return _pageColors[pageName]?.card ??
        (isDarkMode ? Color.fromARGB(255, 40, 40, 40) : Color(0xFFFFFFFF));
  }

  static Color getBorderForPage(String pageName) {
    return _pageColors[pageName]?.border ??
        (isDarkMode ? Color.fromARGB(255, 60, 60, 60) : Color(0xFFE0E0E0));
  }

  static Color getAccentBGForPage(String pageName) {
    return _pageColors[pageName]?.accentBG ??
        (isDarkMode ? Color(0xFF008080) : Color.fromARGB(255, 255, 255, 255));
  }

  // Legacy getters
  static Color get primary => getBackgroundForPage(_currentPage);
  static Color get secondary => getTextPrimaryForPage(_currentPage);
  static Color get accent => getAccentForPage(_currentPage);
  static Color get accentBG => getAccentBGForPage(_currentPage);
  static Color get background => getBackgroundForPage(_currentPage);
  static Color get darkBackground => Color.fromARGB(255, 28, 28, 28);
  static Color get textPrimary => getTextPrimaryForPage(_currentPage);
  static Color get textSecondary => getTextSecondaryForPage(_currentPage);
  static const Color textaccent = Color(0xFF008080);
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;
  static const Color warning = Colors.amber;
  static Color get card => getCardForPage(_currentPage);
  static Color get border => getBorderForPage(_currentPage);
}