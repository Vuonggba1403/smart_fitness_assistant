import 'package:flutter/material.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';

class DailyActivitySection extends StatefulWidget {
  final double mediaWidth;

  const DailyActivitySection({
    super.key,
    required this.mediaWidth,
  });

  @override
  State<DailyActivitySection> createState() => _DailyActivitySectionState();
}

class _DailyActivitySectionState extends State<DailyActivitySection> {
  final _supabase = Supabase.instance.client;

  int _totalWaterMl = 0;
  int _goalMl = 2000;
  List<WaterIntake> _waterIntakes = [];
  bool _isLoading = true;

  int _completedExercises = 0;
  int _totalExercises = 0;
  DateTime? _lastLoadedDate;

  @override
  void initState() {
    super.initState();
    _loadWaterData();
    _loadDailyExerciseStats();
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
          _waterIntakes = intakes.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading water data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDailyExerciseStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // ✅ Load tổng số bài tập từ exercise_items (tất cả bài tập trong hệ thống)
      final totalExercisesResponse = await _supabase
          .from('exercise_items')
          .select('id');

      final totalExercisesCount = totalExercisesResponse.length;

      // ✅ Load số bài tập đã hoàn thành HÔM NAY từ history_workout
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('history_workout')
          .select('completed_exercises, total_exercises')
          .eq('for_user', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      int completedToday = 0;

      for (var workout in response) {
        final completed = (workout['completed_exercises'] ?? 0) as int;
        completedToday += completed;
      }

      debugPrint('📊 Exercise stats loaded:');
      debugPrint('   Completed today: $completedToday');
      debugPrint('   Total exercises in system: $totalExercisesCount');
      debugPrint('   Workouts today: ${response.length}');

      if (mounted) {
        setState(() {
          _completedExercises = completedToday;
          _totalExercises = totalExercisesCount;
          _lastLoadedDate = now;
        });
      }
    } catch (e) {
      debugPrint('Error loading exercise stats: $e');
    }
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
              _buildSleepCard(media, theme),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Water Intake",
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
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
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _waterProgressBar(media),
          ),
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
          SimpleAnimationProgressBar(
            height: barHeight,
            width: media.width * 0.07,
            backgroundColor: Colors.grey.shade100,
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
          const SizedBox(width: 12),
          SizedBox(
            height: barHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: milestones.reversed.map((ml) {
                return Text(
                  '${ml}ml',
                  style: TextStyle(
                    color: TColor.gray.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard(Size media, ThemeData theme) {
    return _baseCard(
      height: media.width * 0.45,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(theme, "Sleep"),
          _gradientText("8h 20m", TColor.primaryG, fontSize: 14),
          const Spacer(),
          Image.asset(
            "assets/img/sleep_grap.png",
            width: double.maxFinite,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesCard(Size media, ThemeData theme) {
    return _baseCard(
      height: media.width * 0.45,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(theme, "Bài tập"),
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
    final percentage = _totalExercises > 0
        ? (_completedExercises / _totalExercises).clamp(0.0, 1.0) * 100
        : 0.0;

    return Center(
      child: SizedBox(
        width: media.width * 0.2,
        height: media.width * 0.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _exercisesInnerBox(media, percentage),
            SimpleCircularProgressBar(
              progressStrokeWidth: 10,
              backStrokeWidth: 10,
              progressColors: TColor.primaryG,
              backColor: Colors.grey.shade100,
              valueNotifier: ValueNotifier(percentage),
              startAngle: -180,
            ),
          ],
        ),
      ),
    );
  }

  Widget _exercisesInnerBox(Size media, double percentage) {
    return Container(
      width: media.width * 0.15,
      height: media.width * 0.15,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
        borderRadius: BorderRadius.circular(media.width * 0.075),
      ),
      alignment: Alignment.center,
      child: Text(
        "${percentage.toStringAsFixed(0)}%",
        textAlign: TextAlign.center,
        style: TextStyle(color: TColor.white, fontSize: 14),
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
        boxShadow: [BoxShadow(color: theme.shadowColor, blurRadius: 2)],
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
