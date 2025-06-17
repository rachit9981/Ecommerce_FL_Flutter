import 'package:flutter/material.dart';

class ErrorHandler {
  /// Shows a generic error message to the user while logging the actual error
  static void showError(BuildContext context, dynamic error, [String? customMessage]) {
    // Log the actual error for debugging
    print('Error occurred: $error');
    
    // Show generic message to user
    final message = customMessage ?? 'Something went wrong. Please try again.';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a generic error dialog while logging the actual error
  static void showErrorDialog(BuildContext context, dynamic error, [String? customTitle, String? customMessage]) {
    // Log the actual error for debugging
    print('Error occurred: $error');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(customTitle ?? 'Error'),
          content: Text(customMessage ?? 'Something went wrong. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Returns a generic error message while logging the actual error
  static String getErrorMessage(dynamic error, [String? customMessage]) {
    // Log the actual error for debugging
    print('Error occurred: $error');
    
    // Return generic message
    return customMessage ?? 'Something went wrong. Please try again.';
  }

  /// Common error handler for async operations
  static Future<T?> handleAsync<T>(
    Future<T> operation,
    BuildContext context, {
    String? errorMessage,
    bool showSnackBar = true,
  }) async {
    try {
      return await operation;
    } catch (e) {
      print('Async operation error: $e');
      
      if (showSnackBar) {
        showError(context, e, errorMessage);
      }
      
      return null;
    }
  }
}
