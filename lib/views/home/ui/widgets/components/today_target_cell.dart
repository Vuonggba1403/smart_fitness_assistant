import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';

class TodayTargetCell extends StatelessWidget {
  final String icon;
  final String value;
  final String title;
  final String? subtitle; // ✅ THÊM subtitle

  const TodayTargetCell({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
    this.subtitle, // ✅ THÊM
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Container(
      height: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 40, height: 40),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: TColor.primaryColor1,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(title, style: TextStyle(color: TColor.gray, fontSize: 10)),
                // ✅ THÊM subtitle
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      // ignore: deprecated_member_use
                      color: TColor.gray.withOpacity(0.6),
                      fontSize: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
