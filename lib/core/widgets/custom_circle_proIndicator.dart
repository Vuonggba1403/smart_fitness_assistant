import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class CustomCircleProgIndicator extends StatelessWidget {
  const CustomCircleProgIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: TColor.primaryColor1,
        backgroundColor: TColor.white,
      ),
    );
  }
}
