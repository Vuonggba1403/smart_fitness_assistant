import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/views/workout_tracker/logic/cubit/workout_tracker_cubit.dart';
import 'package:smart_fitness_assistant/views/workout_detail/ui/widgets/device_card.dart';

/// Section displaying required equipment/devices for workout
class DevicesSection extends StatelessWidget {
  const DevicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return BlocBuilder<WorkoutTrackerCubit, WorkoutTrackerState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildHeader(context, state, textColor),
            SizedBox(
              height: media.width * 0.5,
              child: _buildDevicesList(context, state, textColor),
            ),
          ],
        );
      },
    );
  }

  /// Build header showing device count
  Widget _buildHeader(
    BuildContext context,
    WorkoutTrackerState state,
    Color? textColor,
  ) {
    int deviceCount = 0;
    if (state is WorkoutDetailLoaded) {
      final uniqueDevices = context
          .read<WorkoutTrackerCubit>()
          .getUniqueDevices(state.exercises);
      deviceCount = uniqueDevices.length;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          LocaleKey.youNeed.tr,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            "$deviceCount ${LocaleKey.item.tr}",
            style: TextStyle(color: textColor?.withOpacity(0.6), fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// Build horizontal scrolling list of devices
  Widget _buildDevicesList(
    BuildContext context,
    WorkoutTrackerState state,
    Color? textColor,
  ) {
    if (state is WorkoutDetailLoading) {
      return CustomCircleProgIndicator();
    }

    if (state is WorkoutDetailError) {
      return Center(
        child: Text(
          "Error: ${state.message}",
          style: TextStyle(color: textColor),
        ),
      );
    }

    if (state is WorkoutDetailEmpty || state is WorkoutTrackerInitial) {
      return Center(
        child: Text(
          LocaleKey.noEquipment.tr,
          style: TextStyle(color: textColor?.withOpacity(0.6)),
        ),
      );
    }

    if (state is WorkoutDetailLoaded) {
      final cubit = context.read<WorkoutTrackerCubit>();
      final exercises = state.exercises;
      final uniqueDevices = cubit.getUniqueDevices(exercises);

      if (uniqueDevices.isEmpty) {
        return Center(
          child: Text(
            LocaleKey.noEquipment.tr,
            style: TextStyle(color: textColor?.withOpacity(0.6)),
          ),
        );
      }

      cubit.getExerciseWithDevice(exercises);

      return ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: uniqueDevices.length,
        itemBuilder: (context, index) {
          final device = uniqueDevices[index];
          return DeviceCard(
            deviceName: device.localizedName,
            imageUrl: device.imgUrl ?? '',
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
