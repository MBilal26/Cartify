import 'package:flutter/material.dart';
import '../colors.dart';

/// Utility class for showing snackbars with consistent styling
class SnackBarUtils {
  /// Shows a success snackbar with a check icon
  ///
  /// Example:
  /// ```dart
  /// SnackBarUtils.showSuccess(context, 'Profile updated successfully!');
  /// ```
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'ADLaMDisplay'),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Shows an error snackbar with an error icon
  ///
  /// Example:
  /// ```dart
  /// SnackBarUtils.showError(context, 'Something went wrong!');
  /// ```
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'ADLaMDisplay'),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Shows a warning snackbar with a warning icon
  ///
  /// Example:
  /// ```dart
  /// SnackBarUtils.showWarning(context, 'Please check your input');
  /// ```
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'ADLaMDisplay'),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Shows an info snackbar with an info icon
  ///
  /// Example:
  /// ```dart
  /// SnackBarUtils.showInfo(context, 'Swipe to delete items');
  /// ```
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'ADLaMDisplay'),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.accent,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Shows a custom snackbar with custom color and icon
  ///
  /// Example:
  /// ```dart
  /// SnackBarUtils.showCustom(
  ///   context,
  ///   'Custom message',
  ///   color: Colors.purple,
  ///   icon: Icons.star,
  /// );
  /// ```
  static void showCustom(
    BuildContext context,
    String message, {
    Color? color,
    IconData? icon,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'ADLaMDisplay'),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? AppColors.accent,
        duration: duration ?? const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
