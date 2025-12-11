import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

/// ✅ Widget: Post Creation Card (phần đầu để user tạo post)
class SocialPostCreationCard extends StatelessWidget {
  final Color? textColor;
  final ThemeData theme;
  final VoidCallback onTap;

  const SocialPostCreationCard({
    super.key,
    required this.textColor,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ User avatar + input
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/img/u2.png'),
                backgroundColor: TColor.primaryColor1.withOpacity(0.3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: TColor.gray.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Bạn có gì mới? 💭',
                      style: TextStyle(
                        color: textColor?.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ Action buttons
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.scaffoldBackgroundColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 20,
                          color: TColor.primaryColor1,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ảnh/Video',
                          style: TextStyle(
                            color: TColor.primaryColor1,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.scaffoldBackgroundColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sentiment_satisfied_outlined,
                          size: 20,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cảm xúc',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
