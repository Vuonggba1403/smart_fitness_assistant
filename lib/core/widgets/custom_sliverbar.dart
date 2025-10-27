import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/theme/ui/app_theme.dart';

class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar({super.key, this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      elevation: 0,
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          height: 40,
          width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.textFieldDecoration.color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            "assets/img/black_btn.png",
            width: 15,
            height: 15,
            color: textColor,
            fit: BoxFit.contain,
          ),
        ),
      ),
      title: text != null && text!.isNotEmpty
          ? Text(
              text!,
              style: TextStyle(
                color: theme.textFieldDecoration.color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
      actions: [
        InkWell(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.textFieldDecoration.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/img/more_btn.png",
              width: 15,
              height: 15,
              color: textColor,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
