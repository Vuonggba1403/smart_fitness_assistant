import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import '../functions/colo_extension.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_toggle_switch.dart';

import '../functions/common.dart';

class TodaySleepScheduleRow extends StatefulWidget {
  final Map sObj;
  const TodaySleepScheduleRow({super.key, required this.sObj});

  @override
  State<TodaySleepScheduleRow> createState() => _TodaySleepScheduleRowState();
}

class _TodaySleepScheduleRowState extends State<TodaySleepScheduleRow> {
  bool positive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              widget.sObj["image"].toString(),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.sObj["name"].toString(),
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      ", ${getStringDateToOtherFormate(widget.sObj["time"].toString())}",
                      style: TextStyle(color: TColor.black, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  widget.sObj["duration"].toString(),
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 30,
                child: IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    "assets/img/More_V.png",
                    width: 20,
                    height: 20,
                  ),
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
        ],
      ),
    );
  }
}
