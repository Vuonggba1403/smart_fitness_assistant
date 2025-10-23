import 'package:flutter/material.dart';

class SettingRow extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onPressed;
  const SettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 🌙 Lấy theme động
    final textColor = theme.textTheme.bodyMedium?.color; // Màu text chính
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        height: 30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(icon, height: 15, width: 15, fit: BoxFit.contain),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: textColor, fontSize: 12),
              ),
            ),
            Image.asset(
              "assets/img/p_next.png",
              height: 12,
              width: 12,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
