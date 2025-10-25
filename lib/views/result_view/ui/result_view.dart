import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/appbar_cus.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/views/result_view/logic/cubit/result_cubit.dart';
import 'package:smart_fitness_assistant/views/result_view/ui/widgets/photo_view.dart';
import 'package:smart_fitness_assistant/views/result_view/ui/widgets/statistic_view.dart';

class ResultView extends StatelessWidget {
  final DateTime date1;
  final DateTime date2;

  const ResultView({super.key, required this.date1, required this.date2});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResultCubit(),
      child: _ResultViewBody(date1: date1, date2: date2),
    );
  }
}

class _ResultViewBody extends StatelessWidget {
  final DateTime date1;
  final DateTime date2;

  const _ResultViewBody({super.key, required this.date1, required this.date2});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    return Scaffold(
      appBar: CustomAppBar(title: "Result"),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<ResultCubit, int>(
        builder: (context, selectedTab) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  _buildSwitchBar(context, media, selectedTab, cardColor),
                  const SizedBox(height: 20),
                  if (selectedTab == 0)
                    PhotoView(date1: date1, date2: date2)
                  else
                    StatisticView(date1: date1, date2: date2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitchBar(
    BuildContext context,
    Size media,
    int selectedTab,
    Color cardColor,
  ) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            alignment: selectedTab == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: (media.width * 0.5) - 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: TColor.primaryG),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => context.read<ResultCubit>().selectTab(0),
                    child: Center(
                      child: Text(
                        "Photo",
                        style: TextStyle(
                          color: selectedTab == 0 ? TColor.white : TColor.gray,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => context.read<ResultCubit>().selectTab(1),
                    child: Center(
                      child: Text(
                        "Statistic",
                        style: TextStyle(
                          color: selectedTab == 1 ? TColor.white : TColor.gray,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
