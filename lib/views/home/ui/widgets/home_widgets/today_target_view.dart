import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/common_widget/round_button.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/views/home/ui/widgets/activity_tracker_view.dart';

class TodayTargetView extends StatelessWidget {
  const TodayTargetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: TColor.primaryColor2.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Today Target",
            style: TextStyle(
              color: TColor.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            width: 80,
            height: 25,
            child: RoundButton(
              title: "Check",
              type: RoundButtonType.bgGradient,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityTrackerView(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
