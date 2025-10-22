import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';

import '../../../../core/functions/colo_extension.dart';
import '../../../../core/widgets/notification_row.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List notificationArr = [
    {
      "image": "assets/img/Workout1.png",
      "title": "Hey, it’s time for lunch",
      "time": "About 1 minutes ago",
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "Don’t miss your lowerbody workout",
      "time": "About 3 hours ago",
    },
    {
      "image": "assets/img/Workout3.png",
      "title": "Hey, let’s add some meals for your b",
      "time": "About 3 hours ago",
    },
    {
      "image": "assets/img/Workout1.png",
      "title": "Congratulations, You have finished A..",
      "time": "29 May",
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "Hey, it’s time for lunch",
      "time": "8 April",
    },
    {
      "image": "assets/img/Workout3.png",
      "title": "Ups, You have missed your Lowerbo...",
      "time": "8 April",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Notification"),
      backgroundColor: TColor.white,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        itemBuilder: ((context, index) {
          var nObj = notificationArr[index] as Map? ?? {};
          return NotificationRow(nObj: nObj);
        }),
        separatorBuilder: (context, index) {
          return Divider(color: TColor.gray.withOpacity(0.5), height: 1);
        },
        itemCount: notificationArr.length,
      ),
    );
  }
}
