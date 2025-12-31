/// Application-wide constants for Cartify
///
/// This file contains all constant values used throughout the application
/// to maintain consistency and prevent typos.
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // ==================== PAGE IDs ====================
  /// Page identifiers for theming and navigation
  static const String pageHome = 'HOME';
  static const String pageProfile = 'PROFILE';
  static const String pageCart = 'CART';
  static const String pageCheckout = 'CHECKOUT';
  static const String pageLogin = 'LOGIN';
  static const String pageRewards = 'REWARDS';
  static const String pageCategories = 'CATEGORIES';
  static const String pageProducts = 'PRODUCTS';
  static const String pageProductDetail = 'PRODUCT_DETAIL';
  static const String pageCustomization = 'CUSTOMIZATION';
  static const String pageAboutUs = 'ABOUT_US';
  static const String pagePrivacyPolicy = 'PRIVACY_POLICY';

  // ==================== FIRESTORE COLLECTIONS ====================
  /// Collection names in Firestore database
  static const String collectionUsers = 'users';
  static const String collectionProducts = 'products';
  static const String collectionCart = 'cart';
  static const String collectionOrders = 'orders';
  static const String collectionRewards = 'rewards';
  static const String collectionOtpVerifications = 'otp_verifications';
  static const String collectionPasswordResetOtp = 'password_reset_otp';
  static const String collectionCategories = 'categories';
  static const String collectionBanners = 'banners';
  static const String collectionReviews = 'reviews';

  // ==================== OTP CONFIGURATION ====================
  /// OTP-related constants
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  static const int resendTimerSeconds = 60;
  static const int emailTimeoutSeconds = 30;

  // ==================== VALIDATION ====================
  /// Input validation constraints
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 11;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // ==================== WALLET ====================
  /// Wallet transaction limits
  static const double minWalletAmount = 1.0;
  static const double maxWalletAmount = 50000.0;

  // ==================== PAGINATION ====================
  /// Pagination settings
  static const int productsPerPage = 20;
  static const int ordersPerPage = 10;
  static const int reviewsPerPage = 5;

  // ==================== ANIMATION ====================
  /// Animation durations (in milliseconds)
  static const int splashDuration = 4000;
  static const int fadeAnimationDuration = 300;
  static const int shimmerDuration = 2500;

  // ==================== CART ====================
  /// Shopping cart limits
  static const int maxCartQuantity = 99;
  static const int minCartQuantity = 1;

  // ==================== REWARDS ====================
  /// Reward points configuration
  static const int pointsPerPurchase = 10; // Points per 100 Rs
  static const int signupBonusPoints = 50;
  static const int referralBonusPoints = 100;

  // ==================== API & NETWORK ====================
  /// Network configuration
  static const int requestTimeoutSeconds = 30;
  static const int maxRetries = 3;
}
