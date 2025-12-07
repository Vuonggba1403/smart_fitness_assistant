import 'package:flutter/material.dart';

/// Widget header section tái sử dụng cho các danh sách
/// Hiển thị title bên trái và action button bên phải
class CustomSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? textColor;

  const CustomSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionPressed,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextColor = textColor ?? theme.textTheme.bodyMedium?.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: defaultTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (actionText != null && onActionPressed != null)
          TextButton(
            onPressed: onActionPressed,
            child: Text(
              actionText!,
              style: TextStyle(
                color: defaultTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
