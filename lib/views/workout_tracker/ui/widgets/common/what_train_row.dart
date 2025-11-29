import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_fitness_assistant/core/functions/naviga_to.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/ui/widgets/workour_detail_view.dart';
import '../../../../../core/functions/colo_extension.dart';
import '../../../../../core/widgets/round_button.dart';

/// Widget hiển thị một row của workout/exercise
///
/// Thay đổi chính:
/// - Sử dụng CachedNetworkImage thay vì Image.network để cache ảnh
/// - Sử dụng wObj["img_url"] từ Supabase
/// - Sử dụng wObj["title_ex"] từ database
/// - Hiển thị exercise_count và duration_mins (hardcoded)
class WhatTrainRow extends StatelessWidget {
  /// Đối tượng chứa thông tin workout
  /// Các key cần có:
  /// - img_url: URL hình ảnh từ Supabase
  /// - title_ex: Tên bài tập
  /// - exercise_count: Số lượng bài tập (hardcoded)
  /// - duration_mins: Thời gian tính bằng phút (hardcoded)
  final Map wObj;

  const WhatTrainRow({super.key, required this.wObj});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppTheme.gradientColors1(context)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // Hình ảnh được bọc trong Container tròn
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.54),
                borderRadius: BorderRadius.circular(40),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: CachedNetworkImage(
                  imageUrl: wObj["img_url"]?.toString() ?? '',
                  fit: BoxFit.cover,
                  // Hiển thị loading progress khi đang tải ảnh
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: TColor.primaryColor2,
                      strokeWidth: 2,
                    ),
                  ),
                  // Hiển thị icon khi có lỗi load ảnh
                  errorWidget: (context, url, error) =>
                      Icon(Icons.fitness_center, size: 40, color: TColor.gray),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên bài tập từ database
                  Text(
                    wObj["title_ex"]?.toString() ?? 'Workout',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Thông tin số lượng bài tập và thời gian (hardcoded từ cubit)
                  Text(
                    "${wObj["exercise_count"]?.toString() ?? '0'} Exercises | ${wObj["duration_mins"]?.toString() ?? '0'}mins",
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Icon mũi tên để chỉ ra có thể click
            Icon(Icons.arrow_circle_right_rounded, color: TColor.black),
          ],
        ),
      ),
    );
  }
}
