import 'package:flutter/material.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/raw_delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:delightful_toast/toast/utils/mock.dart';
import 'package:delightful_toast/toast/utils/utils.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

// Flag toàn cục để tránh toast chồng
bool _isShowingToast = false;

void showCustomDelightToastBar(
  BuildContext context,
  String message,
  Icon icon,
) {
  if (_isShowingToast) return; // đang có toast -> không show thêm

  _isShowingToast = true;

  DelightToastBar(
    builder: (context) {
      final theme = Theme.of(context);
      final textColor = theme.textTheme.bodyMedium?.color;
      final cardColor = theme.cardColor;
      return ToastCard(
        color: cardColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 5),
            Text(
              message,
              style: TextStyle(
                fontFamily: "OpenSans",
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    },
    position: DelightSnackbarPosition.bottom,
    autoDismiss: true,
    snackbarDuration: const Duration(seconds: 2),
  ).show(context);

  Future.delayed(const Duration(seconds: 2), () {
    _isShowingToast = false;
  });
}
