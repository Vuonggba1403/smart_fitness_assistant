import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';

class CustomDialog {
  static void show(BuildContext context, {required String message}) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // cho gradient hiển thị
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              // 🎨 Nền gradient
              gradient: LinearGradient(
                colors: AppTheme.gradientColors(context),
              ),
              borderRadius: BorderRadius.circular(16),
              // Viền trắng quanh dialog
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nội dung thông báo
                  Text(
                    message,
                    style: TextStyle(fontSize: 16, color: textColor),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Nút OK
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: Text("OK", style: TextStyle(color: textColor)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
