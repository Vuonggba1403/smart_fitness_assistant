import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

class AppConfirmDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onYes,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child:  Text(LocaleKey.buttonNo.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onYes();
            },
            child:  Text(LocaleKey.buttonYes.tr, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
