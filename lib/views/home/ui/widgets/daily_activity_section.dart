import 'dart:async'; // ✅ THÊM import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';

class DailyActivitySection extends StatefulWidget {
  final double mediaWidth;

  const DailyActivitySection({super.key, required this.mediaWidth});

  @override
  State<DailyActivitySection> createState() => _DailyActivitySectionState();
}

class _DailyActivitySectionState extends State<DailyActivitySection> {
  final _supabase = Supabase.instance.client;

  int _totalWaterMl = 0;
  int _goalMl = 2000;

  int _completedExercises = 0;
  int _totalExercises = 0;

  int _totalCalories = 0;
  int? _calorieGoal; // ✅ Thay đổi từ int thành int?

  // ✅ THÊM: Persistent ValueNotifier cho progress
  late ValueNotifier<double> _exerciseProgressNotifier;

  @override
  void initState() {
    super.initState();
    // ✅ Tạo ValueNotifier một lần duy nhất
    _exerciseProgressNotifier = ValueNotifier<double>(0.0);
    _loadWaterData();
    _loadDailyExerciseStats();
    _loadDailyCalories();

    // ✅ THÊM: Auto refresh mỗi 5 giây
    _startAutoRefresh();
  }

  Timer? _refreshTimer;

  /// ✅ Auto refresh calories every 5 seconds
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadDailyCalories();
      }
    });
  }

  Future<void> _loadWaterData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final settingsResponse = await _supabase
          .from('water_goal_settings')
          .select('daily_goal_ml')
          .eq('for_user', userId)
          .maybeSingle();

      if (settingsResponse != null) {
        _goalMl = settingsResponse['daily_goal_ml'] ?? 2000;
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('water_intake')
          .select()
          .eq('for_user', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: false);

      final intakes = response
          .map((json) => WaterIntake.fromJson(json))
          .toList();

      final total = intakes.fold<int>(
        0,
        (sum, intake) => sum + intake.amountMl,
      );

      if (mounted) {
        setState(() {
          _totalWaterMl = total;
        });
      }
    } catch (e) {
      debugPrint('Error loading water data: $e');
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _loadDailyExerciseStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // ✅ BƯỚC 1: Đếm TỔNG SỐ exercises trong toàn bộ hệ thống
      final totalExercisesResponse = await _supabase
          .from('exercise_items')
          .select('id')
          .count(CountOption.exact);

      final totalExercisesInSystem = totalExercisesResponse.count;

      debugPrint('📊 Total exercises in system: $totalExercisesInSystem');

      // ✅ BƯỚC 2: Đếm exercises ĐÃ HOÀN THÀNH hôm nay
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('history_workout')
          .select('completed_exercises')
          .eq('for_user', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      debugPrint('📊 Found ${response.length} workout sessions today');

      // ✅ BƯỚC 3: Tính tổng exercises hoàn thành hôm nay
      int totalCompletedToday = 0;

      for (var workout in response) {
        final completed = (workout['completed_exercises'] ?? 0) as int;
        totalCompletedToday += completed;
        debugPrint('  - Session completed: $completed exercises');
      }

      debugPrint('📊 Daily stats:');
      debugPrint('   Completed today: $totalCompletedToday');
      debugPrint('   Total in system: $totalExercisesInSystem');
      debugPrint('   Sessions today: ${response.length}');

      if (mounted) {
        // ✅ BƯỚC 4: Tính % dựa trên TỔNG SỐ exercises trong hệ thống
        final percentage = totalExercisesInSystem > 0
            ? (totalCompletedToday / totalExercisesInSystem).clamp(0.0, 1.0) *
                  100
            : 0.0;

        setState(() {
          _completedExercises = totalCompletedToday;
          _totalExercises =
              totalExercisesInSystem; // ✅ Tổng trong hệ thống (12)
        });

        // ✅ UPDATE ValueNotifier
        _exerciseProgressNotifier.value = percentage;

        debugPrint(
          '✅ Updated UI: $_completedExercises/$_totalExercises (${percentage.toStringAsFixed(1)}%)',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading exercise stats: $e');
    }
  }

  /// ✅ Load daily calories từ user_meals table
  Future<void> _loadDailyCalories() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'; // ✅ FIX: Thêm dấu ngoặc

      // ✅ Lấy goal từ user_activity_preferences (không reset)
      final preferencesResponse = await _supabase
          .from('user_activity_preferences')
          .select('daily_calorie_target')
          .eq('for_user', userId)
          .maybeSingle();

      if (preferencesResponse != null &&
          preferencesResponse['daily_calorie_target'] != null) {
        _calorieGoal = preferencesResponse['daily_calorie_target'] as int;
      } else {
        _calorieGoal = null;
      }

      // ✅ Lấy meals của ngày hôm nay từ user_meals
      final response = await _supabase
          .from('user_meals')
          .select('calories')
          .eq('for_user', userId)
          .eq('meal_date', dateStr);

      // ✅ Tính tổng calo
      int totalCalories = 0;
      for (var meal in response) {
        totalCalories += (meal['calories'] as int? ?? 0);
      }

      if (mounted) {
        setState(() {
          _totalCalories = totalCalories;
        });
      }

      debugPrint(
        '🍽️ Daily calories loaded: $_totalCalories / ${_calorieGoal ?? "--"}',
      );
    } catch (e) {
      debugPrint('❌ Error loading calories: $e');
    }
  }

  @override
  void dispose() {
    // ✅ Dispose ValueNotifier
    _exerciseProgressNotifier.dispose();
    _refreshTimer?.cancel(); // ✅ Cancel timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: _buildWaterIntakeCard(media, theme)),
        SizedBox(width: media.width * 0.05),
        Expanded(
          child: Column(
            children: [
              _buildCaloCard(media, theme), // ✅ ĐỔI từ _buildSleepCard
              SizedBox(height: media.width * 0.05),
              _buildExercisesCard(media, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaterIntakeCard(Size media, ThemeData theme) {
    final textColor = theme.textTheme.bodyMedium?.color;
    return _baseCard(
      height: media.width * 0.95,
      theme: theme,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _gradientText(
                "${(_totalWaterMl / 1000).toStringAsFixed(1)}L",
                TColor.primaryG,
                fontSize: 14,
              ),
              Text(
                " / ${(_goalMl / 1000).toStringAsFixed(1)}L",
                style: TextStyle(
                  color: textColor?.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Expanded(child: _waterProgressBar(media)),
        ],
      ),
    );
  }

  Widget _waterProgressBar(Size media) {
    final progress = _goalMl > 0
        ? (_totalWaterMl / _goalMl).clamp(0.0, 1.0)
        : 0.0;

    final milestones = List.generate(11, (index) {
      return (_goalMl / 10 * index).round();
    });

    final barHeight = media.width * 0.85;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ LEFT: Vertical Progress Bar with milestone markers
          Stack(
            children: [
              // ✅ 1. Background container với góc tròn (nằm dưới)
              Container(
                width: media.width * 0.08,
                height: barHeight,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: TColor.gray.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
              ),

              // ✅ 2. Progress bar (nằm giữa)
              SimpleAnimationProgressBar(
                height: barHeight,
                width: media.width * 0.08,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.purple,
                ratio: progress,
                direction: Axis.vertical,
                curve: Curves.fastLinearToSlowEaseIn,
                duration: const Duration(seconds: 3),
                borderRadius: BorderRadius.circular(15),
                gradientColor: LinearGradient(
                  colors: TColor.primaryG,
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),

              // ✅ 3. Milestone markers - Wrap với ClipRect
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: ClipRect(
                  child: CustomPaint(
                    painter: _MilestoneMarkerPainter(
                      milestonesCount: 11,
                      color: TColor.gray.withOpacity(0.5),
                      barWidth: media.width * 0.08,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // ✅ RIGHT: Text labels với ml amount
          SizedBox(
            height: barHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: milestones.reversed.map((ml) {
                final isCurrentLevel =
                    ml <= _totalWaterMl && ml + (_goalMl ~/ 10) > _totalWaterMl;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Text(
                    '${ml}ml',
                    style: TextStyle(
                      color: isCurrentLevel
                          ? TColor.primaryG.first
                          : TColor.gray.withOpacity(0.6),
                      fontSize: isCurrentLevel ? 10 : 9,
                      fontWeight: isCurrentLevel
                          ? FontWeight.w700
                          : FontWeight.w400,
                      height: 1.0,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Build Calorie Card - Hiển thị "--" nếu chưa set goal
  Widget _buildCaloCard(Size media, ThemeData theme) {
    final textColor = theme.textTheme.bodyMedium?.color;

    // ✅ Tính progress dựa trên goal hiện tại
    final progress = _calorieGoal != null && _calorieGoal! > 0
        ? (_totalCalories / _calorieGoal!).clamp(0.0, 1.0)
        : 0.0;

    return _baseCard(
      height: media.width * 0.45,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(theme, "Calories"),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              _gradientText("$_totalCalories", TColor.primaryG, fontSize: 18),
              const SizedBox(width: 4),
              Text(
                // ✅ Hiển thị "--" nếu goal chưa set
                _calorieGoal != null ? "/ $_calorieGoal kcal" : "/ -- kcal",
                style: TextStyle(
                  color: textColor?.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          // ✅ Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: TColor.gray.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _calorieGoal == null
                    ? TColor.gray.withOpacity(0.5) // Xám nếu chưa set
                    : (progress >= 1.0 ? Colors.green : TColor.primaryG.first),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesCard(Size media, ThemeData theme) {
    return _baseCard(
      height: media.width * 0.5,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(theme, LocaleKey.exercises.tr),
          _gradientText(
            "$_completedExercises/${_totalExercises > 0 ? _totalExercises : '0'}",
            TColor.primaryG,
            fontSize: 14,
          ),
          const Spacer(),
          _exercisesCircle(media),
        ],
      ),
    );
  }

  Widget _exercisesCircle(Size media) {
    // ✅ Lấy giá trị hiện tại từ ValueNotifier
    final percentage = _exerciseProgressNotifier.value;

    return Center(
      child: SizedBox(
        width: media.width * 0.22,
        height: media.width * 0.22,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ✅ Outer glow effect
            Container(
              width: media.width * 0.22,
              height: media.width * 0.22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TColor.primaryG.first.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),

            // ✅ Dùng ValueNotifier persistent
            SimpleCircularProgressBar(
              progressStrokeWidth: 12,
              backStrokeWidth: 12,
              progressColors: TColor.primaryG,
              backColor: Colors.grey.withOpacity(0.1),
              valueNotifier:
                  _exerciseProgressNotifier, // ✅ Dùng persistent notifier
              startAngle: -180,
            ),

            // ✅ Inner circle with percentage
            ValueListenableBuilder<double>(
              valueListenable: _exerciseProgressNotifier,
              builder: (context, value, child) {
                return _exercisesInnerBox(media, value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _exercisesInnerBox(Size media, double percentage) {
    return Container(
      width: media.width * 0.155,
      height: media.width * 0.155,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: TColor.primaryG,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: TColor.primaryG.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${percentage.toStringAsFixed(0)}%",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _baseCard({
    required double height,
    required ThemeData theme,
    required Widget child,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _title(ThemeData theme, String text) {
    return Text(
      text,
      style: TextStyle(
        color: theme.textTheme.bodyMedium?.color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _gradientText(
    String text,
    List<Color> colors, {
    double fontSize = 14,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// ✅ CustomPainter để vẽ các vạch milestone - FIX: Không tràn
class _MilestoneMarkerPainter extends CustomPainter {
  final int milestonesCount;
  final Color color;
  final double barWidth;

  _MilestoneMarkerPainter({
    required this.milestonesCount,
    required this.color,
    required this.barWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    final spacing = size.height / (milestonesCount - 1);

    for (int i = 0; i < milestonesCount; i++) {
      final y = i * spacing;
      final double startX = size.width - 6; // sát mép phải
      final double endX = startX - 12; // độ dài vạch 12px

      // ✅ Vẽ vạch ngang từ center ra (không tràn)
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MilestoneMarkerPainter oldDelegate) {
    return oldDelegate.milestonesCount != milestonesCount ||
        oldDelegate.color != color ||
        oldDelegate.barWidth != barWidth;
  }
}
