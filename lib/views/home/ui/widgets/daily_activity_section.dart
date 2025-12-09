import 'package:flutter/material.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_circle_proIndicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ THÊM
import 'package:smart_fitness_assistant/core/models/water_intake.dart'; // ✅ THÊM

class DailyActivitySection extends StatefulWidget {
  final List<Map<String, dynamic>> waterArr; // ✅ Deprecated - sẽ không dùng nữa
  final double mediaWidth;

  const DailyActivitySection({
    super.key,
    required this.waterArr,
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

  @override
  void initState() {
    super.initState();
    _loadWaterData();
  }

  /// ✅ Load dữ liệu water intake thực tế
  Future<void> _loadWaterData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Load goal từ settings
      final settingsResponse = await _supabase
          .from('water_goal_settings')
          .select('daily_goal_ml')
          .eq('for_user', userId)
          .maybeSingle();

      if (settingsResponse != null) {
        _goalMl = settingsResponse['daily_goal_ml'] ?? 2000;
      }

      // Load water intake hôm nay
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
          _waterIntakes = intakes.take(5).toList(); // ✅ Lấy 5 lần gần nhất
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading water data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              _buildCaloriesCard(media, theme),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ WATER INTAKE CARD - Dùng dữ liệu thực
  Widget _buildWaterIntakeCard(Size media, ThemeData theme) {
    return _baseCard(
      height: media.width * 0.95,
      theme: theme,
      child: Row(
        children: [
          _waterProgressBar(media),
          SizedBox(width: 10),
          Expanded(child: _waterInfo(theme, media)),
        ],
      ),
    );
  }

  Widget _waterProgressBar(Size media) {
    // ✅ FIX: Tính progress từ instance variables thay vì state
    final progress = _goalMl > 0
        ? (_totalWaterMl / _goalMl).clamp(0.0, 1.0)
        : 0.0;

    // ✅ Tính các mốc chia đều (10 mốc từ 0 → goalMl)
    final milestones = List.generate(11, (index) {
      return (_goalMl / 10 * index).round();
    });

    // ✅ FIX: Chiều cao của thanh progress
    final barHeight = media.width * 0.85;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center align
      children: [
        // ✅ LEFT: Text labels (200ml, 400ml, ..., 2000ml)
        SizedBox(
          height: barHeight, // ✅ Đặt height = height của progress bar
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
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

        const SizedBox(width: 8), // ✅ Khoảng cách giữa text và bar
        // ✅ RIGHT: Vertical Progress Bar
        SimpleAnimationProgressBar(
          height: barHeight, // ✅ Đồng bộ height
          width: media.width * 0.07,
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.purple,
          ratio: progress, // ✅ Dùng biến progress local
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
      ],
    );
  }

  Widget _waterInfo(ThemeData theme, Size media) {
    final textColor = theme.textTheme.bodyMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Water Intake",
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        // ✅ Hiển thị dữ liệu thực: "1.5 Liters / 2.0L Goal"
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
        const SizedBox(height: 10),
        Text(
          "Real time updates",
          style: TextStyle(color: TColor.gray, fontSize: 12),
        ),

        // ✅ Timeline với dữ liệu thực
        if (_isLoading)
          CustomCircleProgIndicator()
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 20),
        //   child: Center(
        //     child: SizedBox(
        //       width: 20,
        //       height: 20,
        //       child: CircularProgressIndicator(
        //         strokeWidth: 2,
        //         valueColor: AlwaysStoppedAnimation<Color>(
        //           TColor.primaryColor1,
        //         ),
        //       ),
        //     ),
        //   ),
        // )
        else if (_waterIntakes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Chưa uống nước",
              style: TextStyle(color: TColor.gray, fontSize: 10),
            ),
          )
        else
          // ✅ FIX: Wrap timeline trong Expanded để chiếm hết không gian còn lại
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _waterIntakes.asMap().entries.map((entry) {
                final index = entry.key;
                final intake = entry.value;
                final isLast = index == _waterIntakes.length - 1;

                return Expanded(
                  // ✅ FIX: Chia đều không gian cho mỗi item
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // ✅ Kéo dài hết chiều cao
                    children: [
                      _waterTimelineDot(media, isLast),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Align(
                          alignment: Alignment
                              .centerLeft, // ✅ Center text theo chiều dọc
                          child: _waterTimelineText(intake),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _waterTimelineDot(Size media, bool isLast) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: TColor.secondaryColor1.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        if (!isLast)
          Expanded(
            // ✅ FIX: Kéo dài line hết chiều cao còn lại
            child: DottedDashedLine(
              height: double.infinity, // ✅ FIX: Chiều cao tự động
              width: 0,
              dashColor: TColor.secondaryColor1.withOpacity(0.5),
              axis: Axis.vertical,
            ),
          ),
      ],
    );
  }

  // ✅ Format dữ liệu thực
  Widget _waterTimelineText(WaterIntake intake) {
    final timeStr = _formatTimeAgo(intake.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // ✅ Chỉ chiếm không gian cần thiết
      children: [
        Text(timeStr, style: TextStyle(color: TColor.gray, fontSize: 10)),
        _gradientText("${intake.amountMl}ml", TColor.secondaryG, fontSize: 12),
      ],
    );
  }

  /// ✅ Format time ago
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }

  // ---------------------------------------------------------------------------
  // SLEEP CARD
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // CALORIES CARD
  // ---------------------------------------------------------------------------
  Widget _buildCaloriesCard(Size media, ThemeData theme) {
    return _baseCard(
      height: media.width * 0.45,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(theme, "Calories"),
          _gradientText("760 kCal", TColor.primaryG, fontSize: 14),
          const Spacer(),
          _caloriesCircle(media),
        ],
      ),
    );
  }

  Widget _caloriesCircle(Size media) {
    return Center(
      child: SizedBox(
        width: media.width * 0.2,
        height: media.width * 0.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _caloriesInnerBox(media),
            SimpleCircularProgressBar(
              progressStrokeWidth: 10,
              backStrokeWidth: 10,
              progressColors: TColor.primaryG,
              backColor: Colors.grey.shade100,
              valueNotifier: ValueNotifier(50),
              startAngle: -180,
            ),
          ],
        ),
      ),
    );
  }

  Widget _caloriesInnerBox(Size media) {
    return Container(
      width: media.width * 0.15,
      height: media.width * 0.15,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
        borderRadius: BorderRadius.circular(media.width * 0.075),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        child: Text(
          "230kCal\nleft",
          textAlign: TextAlign.center,
          style: TextStyle(color: TColor.white, fontSize: 11),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

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
