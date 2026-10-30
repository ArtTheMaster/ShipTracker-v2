import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Raised when the transactional email backend rejects a request or is not
/// configured for the current build.
class EmailServiceException implements Exception {
  final String message;

  EmailServiceException(this.message);

  @override
  String toString() => message;
}

/// Sends transactional email through the Cloudflare email worker in
/// `backend/email-worker`.
///
/// The worker URL and shared key are supplied at build time so they are not
/// hard-coded into the repository:
///
/// ```
/// flutter build apk \
///   --dart-define=EMAIL_WORKER_URL=https://gjandasher-email.example.workers.dev \
///   --dart-define=EMAIL_API_KEY=your-shared-key
/// ```
///
/// When [isConfigured] is false the app keeps working: staff approvals still
/// update Firestore and password resets fall back to Firebase Auth's built-in
/// email.
class EmailService {
  static const String _workerUrl =
      String.fromEnvironment('EMAIL_WORKER_URL', defaultValue: '');
  static const String _apiKey =
      String.fromEnvironment('EMAIL_API_KEY', defaultValue: '');

  bool get isConfigured => _workerUrl.trim().isNotEmpty;

  Future<void> sendStaffApproved({
    required String to,
    required String name,
  }) {
    return _post('/staff-approved', {
      'to': to.trim(),
      'name': name.trim(),
    });
  }

  Future<void> sendPasswordReset({required String email}) {
    return _post('/password-reset', {
      'email': email.trim(),
    });
  }

  Future<void> _post(String path, Map<String, dynamic> payload) async {
    if (!isConfigured) {
      throw EmailServiceException(
        'Email service is not configured. Build with EMAIL_WORKER_URL and '
        'EMAIL_API_KEY to enable transactional email.',
      );
    }

    final baseUrl = _workerUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$baseUrl$path');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (_apiKey.trim().isNotEmpty) 'x-api-key': _apiKey.trim(),
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw EmailServiceException(
          'Email service returned ${response.statusCode}: ${response.body}',
        );
      }
    } on TimeoutException {
      throw EmailServiceException(
        'The email service timed out. Please try again.',
      );
    } on EmailServiceException {
      rethrow;
    } catch (e) {
      throw EmailServiceException('Could not reach the email service: $e');
    }
  }
}
