import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/widgets/icon_title_next_row.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/views/photo_progress/ui/widgets/result_view.dart';

class ComparisonView extends StatefulWidget {
  const ComparisonView({super.key});

  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Comparison"),
      backgroundColor: TColor.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            IconTitleNextRow(
              icon: "assets/img/date.png",
              title: "Select Month 1",
              time: "May",
              onPressed: () {},
              color: TColor.lightGray,
            ),
            const SizedBox(height: 15),
            IconTitleNextRow(
              icon: "assets/img/date.png",
              title: "Select Month 2",
              time: "select Month",
              onPressed: () {},
              color: TColor.lightGray,
            ),
            const Spacer(),
            RoundButton(
              title: "Compare",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultView(
                      date1: DateTime(2023, 5, 1),
                      date2: DateTime(2023, 6, 1),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
