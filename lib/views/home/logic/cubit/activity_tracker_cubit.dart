import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';

part 'activity_tracker_state.dart';

class ActivityTrackerCubit extends Cubit<ActivityTrackerState> {
  final _supabase = Supabase.instance.client;

  ActivityTrackerCubit() : super(ActivityTrackerInitial()) {
    loadTodayData();
  }

  /// ✅ Load dữ liệu HÔM NAY - Tự động reset mỗi ngày
  Future<void> loadTodayData() async {
    emit(ActivityTrackerLoading());

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(ActivityTrackerError('User not authenticated'));
        return;
      }

      // ✅ Load water intake HÔM NAY (tự động reset mỗi ngày)
      final waterData = await _loadTodayWaterIntake(userId);

      // Load settings để lấy goal
      final settings = await _loadWaterSettings(userId);

      emit(
        ActivityTrackerLoaded(
          totalWaterMl: waterData['total'] as int,
          waterGoalMl: settings.dailyGoalMl,
          waterIntakes: waterData['intakes'] as List<WaterIntake>,
        ),
      );
    } catch (e) {
      emit(ActivityTrackerError(e.toString()));
    }
  }

  /// ✅ Load water intake HÔM NAY - Chỉ lấy dữ liệu trong ngày
  Future<Map<String, dynamic>> _loadTodayWaterIntake(String userId) async {
    // ✅ Lấy thời gian đầu và cuối ngày HÔM NAY
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day); // 00:00:00
    final endOfDay = startOfDay.add(const Duration(days: 1)); // 23:59:59

    print('📅 Loading water intake for TODAY:');
    print('   Start: $startOfDay');
    print('   End: $endOfDay');

    final response = await _supabase
        .from('water_intake')
        .select()
        .eq('for_user', userId)
        .gte('created_at', startOfDay.toIso8601String())
        .lt('created_at', endOfDay.toIso8601String())
        .order('created_at', ascending: false);

    final intakes = response.map((json) => WaterIntake.fromJson(json)).toList();
    final total = intakes.fold<int>(0, (sum, intake) => sum + intake.amountMl);

    print('💧 Total water today: ${total}ml (${intakes.length} intakes)');

    return {'total': total, 'intakes': intakes};
  }

  /// Load water settings
  Future<WaterGoalSettings> _loadWaterSettings(String userId) async {
    final response = await _supabase
        .from('water_goal_settings')
        .select()
        .eq('for_user', userId)
        .maybeSingle();

    if (response != null) {
      return WaterGoalSettings.fromJson(response);
    }

    return WaterGoalSettings(forUser: userId, dailyGoalMl: 2000);
  }
}
