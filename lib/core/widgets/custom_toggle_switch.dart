import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';

class CustomToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAnimatedToggleSwitch<bool>(
      current: value,
      values: const [false, true],
      spacing: 0.0,
      indicatorSize: const Size.square(30.0),
      animationDuration: const Duration(milliseconds: 200),
      animationCurve: Curves.linear,
      onChanged: onChanged,
      iconBuilder: (context, local, global) {
        return const SizedBox();
      },
      cursors: const ToggleCursors(defaultCursor: SystemMouseCursors.click),
      onTap: (val) => onChanged(!value),
      iconsTappable: false,
      wrapperBuilder: (context, global, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 10.0,
              right: 10.0,
              height: 30.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: TColor.secondaryG, // gradient màu
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                ),
              ),
            ),
            child,
          ],
        );
      },
      foregroundIndicatorBuilder: (context, global) {
        return SizedBox.fromSize(
          size: const Size(10, 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.all(Radius.circular(50.0)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  spreadRadius: 0.05,
                  blurRadius: 1.1,
                  offset: Offset(0.0, 0.8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
