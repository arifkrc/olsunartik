import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/chat/presentation/shift_notes_screen.dart';

/// Centralized navigation service
/// Eliminates duplicate navigation logic across screens
class NavigationService {
  NavigationService._(); // Private constructor

  /// Navigate to home screen (pop to root)
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Navigate to shift notes
  static void navigateToShiftNotes(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ShiftNotesScreen()));
  }

  /// Navigate back
  static void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Navigate to login screen (replace)
  static void navigateToLogin(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  /// Handle sidebar navigation
  static void handleSidebarNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        navigateToHome(context);
        break;
      case 1:
        navigateBack(context);
        break;
      case 3:
        navigateToShiftNotes(context);
        break;
      default:
        break;
    }
  }

  /// Show dialog helper
  static Future<T?> showCustomDialog<T>(BuildContext context, Widget dialog) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (_) => dialog,
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
