import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ THÊM import
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart'; // ✅ THÊM import

class WorkoutRow extends StatelessWidget {
  final Map wObj;
  const WorkoutRow({super.key, required this.wObj});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    // ✅ Tính % hoàn thành
    final progress = (wObj["progress"] as num?)?.toDouble() ?? 0.0;
    final imageUrl = wObj["image"]?.toString() ?? '';
    final isNetworkImage = imageUrl.startsWith('http');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.primaryColor1.withOpacity(0.3),
            TColor.primaryColor2.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: TColor.primaryColor1, width: 1),
      ),
      child: Row(
        children: [
          // ✅ Ảnh với checkmark nếu hoàn thành 100%
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isNetworkImage
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 70,
                          height: 70,
                          color: TColor.gray.withOpacity(0.2),
                          child: CustomCircleProgIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 70,
                          height: 70,
                          color: TColor.gray.withOpacity(0.2),
                          child: Icon(
                            Icons.fitness_center,
                            color: TColor.gray,
                            size: 30,
                          ),
                        ),
                      )
                    : Image.asset(
                        imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: TColor.gray.withOpacity(0.2),
                            child: Icon(
                              Icons.fitness_center,
                              color: TColor.gray,
                              size: 30,
                            ),
                          );
                        },
                      ),
              ),
              if (progress == 1.0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wObj["name"].toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // ✅ Hiển thị thời gian tương đối
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: TColor.gray),
                    const SizedBox(width: 4),
                    Text(
                      "${wObj["time_ago"]}",
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // ✅ Progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: TColor.gray.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0
                                ? Colors.green
                                : TColor.primaryColor1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
