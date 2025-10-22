import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_toggle_switch.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import '../../core/functions/common.dart';
import '../../core/widgets/icon_title_next_row.dart';

class SleepAddAlarmView extends StatefulWidget {
  final DateTime date;
  const SleepAddAlarmView({super.key, required this.date});

  @override
  State<SleepAddAlarmView> createState() => _SleepAddAlarmViewState();
}

class _SleepAddAlarmViewState extends State<SleepAddAlarmView> {
  bool positive = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppBar(title: "Add Alarm"),
      backgroundColor: TColor.white,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            IconTitleNextRow(
              icon: "assets/img/Bed_Add.png",
              title: "Bedtime",
              time: "09:00 PM",
              color: TColor.lightGray,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            IconTitleNextRow(
              icon: "assets/img/HoursTime.png",
              title: "Hours of sleep",
              time: "8hours 30minutes",
              color: TColor.lightGray,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            IconTitleNextRow(
              icon: "assets/img/Repeat.png",
              title: "Repeat",
              time: "Mon to Fri",
              color: TColor.lightGray,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 15),
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/img/Vibrate.png",
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Vibrate When Alarm Sound",
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                  ),

                  SizedBox(
                    height: 30,
                    child: Transform.scale(
                      scale: 0.7,
                      child: CustomToggleSwitch(
                        value: positive,
                        onChanged: (value) => setState(() => positive = value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            RoundButton(title: "Add", onPressed: () {}),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
