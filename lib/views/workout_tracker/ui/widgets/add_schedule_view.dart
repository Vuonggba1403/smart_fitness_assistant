import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';

import '../../../../core/functions/common.dart';
import '../../../../core/widgets/icon_title_next_row.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;
  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppBar(title: "Add Schedule"),
      backgroundColor: TColor.white,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset("assets/img/date.png", width: 20, height: 20),
                const SizedBox(width: 8),
                Text(
                  dateToString(widget.date, formatStr: "E, dd MMMM yyyy"),
                  style: TextStyle(color: TColor.gray, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Time",
              style: TextStyle(
                color: TColor.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: media.width * 0.35,
              child: CupertinoDatePicker(
                onDateTimeChanged: (newDate) {},
                initialDateTime: DateTime.now(),
                use24hFormat: false,
                minuteInterval: 1,
                mode: CupertinoDatePickerMode.time,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Details Workout",
              style: TextStyle(
                color: TColor.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            IconTitleNextRow(
              icon: "assets/img/choose_workout.png",
              title: "Choose Workout",
              time: "Upperbody",
              color: TColor.lightGray,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            IconTitleNextRow(
              icon: "assets/img/difficulity.png",
              title: "Difficulity",
              time: "Beginner",
              color: TColor.lightGray,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            IconTitleNextRow(
              icon: "assets/img/repetitions.png",
              title: "Custom Repetitions",
              time: "",
              color: TColor.lightGray,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            IconTitleNextRow(
              icon: "assets/img/repetitions.png",
              title: "Custom Weights",
              time: "",
              color: TColor.lightGray,
              onPressed: () {},
            ),
            Spacer(),
            RoundButton(title: "Save", onPressed: () {}),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
