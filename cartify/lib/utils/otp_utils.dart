import 'dart:math';

/// Utility class for OTP (One-Time Password) operations
class OTPUtils {
  /// Generates a random 6-digit OTP
  ///
  /// Returns a [String] containing 6 random digits (0-9)
  ///
  /// Example:
  /// ```dart
  /// final otp = OTPUtils.generateOTP();
  /// print(otp); // Output: "123456"
  /// ```
  static String generateOTP({int length = 6}) {
    // Use Random.secure() for cryptographically strong random numbers
    final random = Random.secure();
    final otp = List.generate(length, (_) => random.nextInt(10)).join();

    // Ensure OTP is always the correct length
    if (otp.length != length) {
      throw Exception('OTP generation failed - invalid length: ${otp.length}');
    }

    return otp;
  }

  /// Validates if a string is a valid OTP (only digits)
  ///
  /// Returns `true` if the OTP contains only digits and matches the expected length
  ///
  /// Example:
  /// ```dart
  /// bool isValid = OTPUtils.isValidOTP('123456', length: 6);  // true
  /// bool isValid = OTPUtils.isValidOTP('12ab56', length: 6);  // false
  /// ```
  static bool isValidOTP(String otp, {int length = 6}) {
    if (otp.length != length) return false;
    return RegExp(r'^\d+$').hasMatch(otp);
  }

  /// Formats an OTP string with spaces for better readability
  ///
  /// Example:
  /// ```dart
  /// String formatted = OTPUtils.formatOTP('123456');  // "123 456"
  /// ```
  static String formatOTP(String otp) {
    if (otp.length != 6) return otp;
    return '${otp.substring(0, 3)} ${otp.substring(3)}';
  }
}
