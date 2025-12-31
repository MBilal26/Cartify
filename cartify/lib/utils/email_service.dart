import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for sending emails via EmailJS
///
/// Environment variables required in .env:
/// - EMAILJS_SERVICE_ID
/// - EMAILJS_TEMPLATE_ID_OTP
/// - EMAILJS_TEMPLATE_ID_RESET
/// - EMAILJS_USER_ID
class EmailService {
  // Fallback to hardcoded values if .env not configured
  static String get _serviceId =>
      dotenv.env['EMAILJS_SERVICE_ID'] ?? 'service_igjgdas';

  static String get _templateIdOTP =>
      dotenv.env['EMAILJS_TEMPLATE_ID_OTP'] ?? 'template_ay2511u';

  static String get _templateIdReset =>
      dotenv.env['EMAILJS_TEMPLATE_ID_RESET'] ?? 'template_awim1ts';

  static String get _userId =>
      dotenv.env['EMAILJS_USER_ID'] ?? 'RJ-0Lqr3XZZjw4y1K';

  /// Sends an OTP email to the specified address
  ///
  /// [otp] - The OTP code to send
  /// [email] - The recipient email address
  ///
  /// Throws an exception if the email fails to send
  static Future<void> sendOTPEmail(String otp, String email) async {
    // Validate inputs
    if (otp.isEmpty) {
      throw Exception('OTP is empty - cannot send email');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email address: $email');
    }

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'service_id': _serviceId,
              'template_id': _templateIdOTP,
              'user_id': _userId,
              'template_params': {
                'user_email': email.trim(),
                'to_email': email.trim(),
                'recipient_email': email.trim(),
                'otp_code': otp,
                'message': 'Your OTP code is $otp',
              },
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Email request timed out after 30 seconds');
            },
          );

      if (response.statusCode == 200) {
        // Success
      } else {
        print('[EMAIL] ❌ Email failed with status ${response.statusCode}');
        throw Exception(
          'EmailJS returned status ${response.statusCode}: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      print('[EMAIL] ❌ Network error: $e');
      throw Exception(
        'Network error: $e. Please check your internet connection.',
      );
    } catch (e) {
      print('[EMAIL] ❌ Error sending email: $e');
      rethrow;
    }
  }

  /// Sends a password reset OTP email
  ///
  /// [otp] - The OTP code to send
  /// [email] - The recipient email address
  ///
  /// Throws an exception if the email fails to send
  static Future<void> sendPasswordResetOTP(String otp, String email) async {
    // Validate inputs
    if (otp.isEmpty) {
      throw Exception('OTP is empty - cannot send email');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email address: $email');
    }

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'service_id': _serviceId,
              'template_id': _templateIdReset,
              'user_id': _userId,
              'template_params': {
                'user_email': email.trim(),
                'to_email': email.trim(),
                'recipient_email': email.trim(),
                'otp_code': otp,
                'message': 'Your password reset OTP is $otp',
              },
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Email request timed out after 30 seconds');
            },
          );

      if (response.statusCode == 200) {
        // Success
      } else {
        print(
          '[EMAIL-RESET] ❌ Email failed with status ${response.statusCode}',
        );
        throw Exception(
          'EmailJS returned status ${response.statusCode}: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      print('[EMAIL-RESET] ❌ Network error: $e');
      throw Exception(
        'Network error: $e. Please check your internet connection.',
      );
    } catch (e) {
      print('[EMAIL-RESET] ❌ Error sending email: $e');
      rethrow;
    }
  }
}
