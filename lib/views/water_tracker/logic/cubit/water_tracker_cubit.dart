import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';
import 'package:smart_fitness_assistant/core/services/water_tracker_service.dart';

part 'water_tracker_state.dart';

/// ✨ Cubit đơn giản hơn - business logic đã tách sang Service
class WaterTrackerCubit extends Cubit<WaterTrackerState> {
  final _service = WaterTrackerService();
  bool _hasShownCongratulations = false;

  WaterTrackerCubit() : super(WaterTrackerInitial()) {
    loadTodayWaterIntake();
  }

  /// Load settings + water intake
  Future<void> loadTodayWaterIntake() async {
    emit(WaterTrackerLoading());

    try {
      final userId = _service.currentUserId;
      if (userId == null) {
        emit(WaterTrackerError('User not authenticated'));
        return;
      }

      final settings = await _service.loadSettings(userId);
      final intakes = await _service.loadTodayIntakes(userId);
      final totalMl = _service.calculateTotalMl(intakes);

      if (totalMl < settings.dailyGoalMl) {
        _hasShownCongratulations = false;
      }

      emit(
        WaterTrackerLoaded(
          totalMl: totalMl,
          goalMl: settings.dailyGoalMl,
          intakes: intakes,
          settings: settings,
        ),
      );

      if (settings.reminderEnabled) {
        print('📅 Reminder enabled, scheduling...');
        await _service.scheduleReminders(userId, settings);
      } else {
        print('⚠️ Reminder disabled');
      }
    } catch (e) {
      emit(WaterTrackerError(e.toString()));
    }
  }

  /// Update goal
  Future<void> updateGoal(int newGoalMl) async {
    try {
      final userId = _service.currentUserId;
      if (userId == null) return;

      await _service.updateGoal(userId, newGoalMl);
      await loadTodayWaterIntake();
    } catch (e) {
      print('❌ Error updating goal: $e');
    }
  }

  /// Update reminder settings
  Future<void> updateReminderSettings(WaterGoalSettings newSettings) async {
    try {
      final userId = _service.currentUserId;
      if (userId == null) return;

      print('🔄 Updating reminder settings:');
      print('   Enabled: ${newSettings.reminderEnabled}');
      print('   Interval: ${newSettings.reminderIntervalMinutes}');

      await _service.updateReminderSettings(userId, newSettings);
      await loadTodayWaterIntake();
    } catch (e) {
      print('❌ Error updating reminder: $e');
    }
  }

  /// Thêm lượng nước đã uống
  Future<void> addWaterIntake(int amountMl) async {
    try {
      final userId = _service.currentUserId;
      if (userId == null) return;

      await _service.addWaterIntake(userId, amountMl);
      await loadTodayWaterIntake();

      // Check xem đã đạt goal chưa
      final currentState = state;
      if (currentState is WaterTrackerLoaded) {
        if (currentState.totalMl >= currentState.goalMl &&
            !_hasShownCongratulations) {
          emit(
            WaterGoalAchieved(
              totalMl: currentState.totalMl,
              goalMl: currentState.goalMl,
            ),
          );
          _hasShownCongratulations = true;

          await Future.delayed(const Duration(seconds: 1));
          emit(currentState);
        }
      }
    } catch (e) {
      print('❌ Error adding water intake: $e');
    }
  }

  /// Xóa một lần uống nước
  Future<void> deleteWaterIntake(String id) async {
    try {
      await _service.deleteWaterIntake(id);
      await loadTodayWaterIntake();
    } catch (e) {
      print('❌ Error deleting water intake: $e');
    }
  }

  @override
  Future<void> close() async {
    final userId = _service.currentUserId;
    if (userId != null) {
      await _service.cancelReminders(userId);
    }
    return super.close();
  }
}
