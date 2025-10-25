import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import '../../../../core/functions/common.dart';

class PhotoView extends StatelessWidget {
  final DateTime date1;
  final DateTime date2;

  const PhotoView({super.key, required this.date1, required this.date2});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    final imaArr = [
      {
        "title": "Front Facing",
        "month_1_image": "assets/img/pp_1.png",
        "month_2_image": "assets/img/pp_2.png",
      },
      {
        "title": "Back Facing",
        "month_1_image": "assets/img/pp_3.png",
        "month_2_image": "assets/img/pp_4.png",
      },
      {
        "title": "Left Facing",
        "month_1_image": "assets/img/pp_5.png",
        "month_2_image": "assets/img/pp_6.png",
      },
      {
        "title": "Right Facing",
        "month_1_image": "assets/img/pp_7.png",
        "month_2_image": "assets/img/pp_8.png",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Average Progress",
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              "Good",
              style: TextStyle(
                color: Color(0xFF6DD570),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Stack(
          alignment: Alignment.center,
          children: [
            SimpleAnimationProgressBar(
              height: 20,
              width: media.width - 40,
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.purple,
              ratio: 0.62,
              direction: Axis.horizontal,
              curve: Curves.fastLinearToSlowEaseIn,
              duration: const Duration(seconds: 3),
              borderRadius: BorderRadius.circular(10),
              gradientColor: LinearGradient(
                colors: TColor.primaryG,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            Text("62%", style: TextStyle(color: TColor.white, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateToString(date1, formatStr: "MMMM"),
              style: TextStyle(
                color: TColor.gray,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              dateToString(date2, formatStr: "MMMM"),
              style: TextStyle(
                color: TColor.gray,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: imaArr.length,
          itemBuilder: (context, index) {
            var iObj = imaArr[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(
                  iObj["title"].toString(),
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _imageBox(iObj["month_1_image"] as String),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _imageBox(iObj["month_2_image"] as String),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        RoundButton(
          title: "Back to Home",
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _imageBox(String path) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(path, fit: BoxFit.cover),
      ),
    );
  }
}
