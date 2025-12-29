import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.black87,
    Duration duration = const Duration(seconds: 1),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: behavior,
          duration: duration,
          backgroundColor: backgroundColor,
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  /// ✅ Success snackbar
  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: TColor.primaryColor2,
      icon: Icons.check_circle_outline,
    );
  }

  /// ❌ Error snackbar
  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error_outline,
    );
  }

  /// ℹ️ Info snackbar
  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.blueGrey,
      icon: Icons.info_outline,
    );
  }
}
