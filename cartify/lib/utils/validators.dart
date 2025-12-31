/// Utility class for common input validators
class Validators {
  /// Validates email format
  ///
  /// Returns `null` if valid, error message if invalid
  ///
  /// Example:
  /// ```dart
  /// String? error = Validators.email('test@example.com');  // null (valid)
  /// String? error = Validators.email('invalid-email');     // error message
  /// ```
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  ///
  /// Requires at least 8 characters, 1 uppercase, 1 lowercase, 1 number
  ///
  /// Example:
  /// ```dart
  /// String? error = Validators.password('Pass123!');  // null (valid)
  /// String? error = Validators.password('weak');      // error message
  /// ```
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validates that a field is not empty
  ///
  /// Example:
  /// ```dart
  /// String? error = Validators.required('John Doe');  // null (valid)
  /// String? error = Validators.required('');          // error message
  /// ```
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates phone number format
  ///
  /// Accepts formats: +1234567890, (123) 456-7890, 123-456-7890
  ///
  /// Example:
  /// ```dart
  /// String? error = Validators.phone('+1234567890');  // null (valid)
  /// ```
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates that two passwords match
  ///
  /// Example:
  /// ```dart
  /// String? error = Validators.confirmPassword('Pass123', 'Pass123');  // null
  /// String? error = Validators.confirmPassword('Pass123', 'Pass456');  // error
  /// ```
  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates minimum length
  ///
  /// Example:
  /// ```dart
  /// String? error = Validators.minLength('Hello', 3);  // null (valid)
  /// String? error = Validators.minLength('Hi', 3);     // error
  /// ```
  static String? minLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < length) {
      return '${fieldName ?? 'This field'} must be at least $length characters';
    }

    return null;
  }

  /// Validates maximum length
  ///
  /// Example:
  /// ```dart
  /// String? error = Validators.maxLength('Hello', 10);  // null (valid)
  /// String? error = Validators.maxLength('Very long text', 5);  // error
  /// ```
  static String? maxLength(String? value, int length, {String? fieldName}) {
    if (value != null && value.length > length) {
      return '${fieldName ?? 'This field'} cannot exceed $length characters';
    }

    return null;
  }

  /// Validates that a value is numeric
  ///
  /// Example:
  /// ```dart
  /// String? error = Validators.numeric('123');    // null (valid)
  /// String? error = Validators.numeric('abc');    // error
  /// ```
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a number';
    }

    return null;
  }
}
