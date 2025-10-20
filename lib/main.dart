import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/ui/login/login_view.dart';
import 'package:smart_fitness_assistant/ui/main_tab/main_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/ui/splash/ui/started_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness 3 in 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: TColor.primaryColor1,
        fontFamily: "Poppins",
      ),
      home: const StartedView(),
    );
  }
}
