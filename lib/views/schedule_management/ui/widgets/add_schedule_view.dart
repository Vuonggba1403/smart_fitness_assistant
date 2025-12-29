import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_scaffold_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/core/models/scheduled_workout.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/views/schedule_management/logic/cubit/schedule_cubit.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;

  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  final _supabase = Supabase.instance.client;

  List<ExerciseCategory> _categories = [];
  ExerciseCategory? _selectedCategory;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _hasNotification = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date;
    _selectedTime = TimeOfDay.now();
    _loadCategories();
  }

  /// Tải danh sách categories từ database
  Future<void> _loadCategories() async {
    try {
      final response = await _supabase
          .from('exercise_categories')
          .select()
          .order('title_ex');

      setState(() {
        _categories = response
            .map((json) => ExerciseCategory.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading categories: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Hiển thị time picker
  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  /// Lưu lịch tập mới - ✅ FIX: Chỉ lưu category_id
  Future<void> _save() async {
    if (_selectedCategory == null) {
      AppSnackBar.error(context, 'Vui lòng chọn bài tập');
      return;
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final scheduledTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (scheduledTime.isBefore(DateTime.now())) {
      AppSnackBar.error(context, 'Vui lòng chọn thời gian trong tương lai');
      return;
    }

    // ✅ FIX: Chỉ truyền category_id
    final schedule = ScheduledWorkout(
      forUser: userId,
      categoryId: _selectedCategory!.id!,
      scheduledTime: scheduledTime,
      hasNotification: _hasNotification,
    );

    final success = await context.read<ScheduleCubit>().addSchedule(schedule);

    if (success && mounted) {
      Navigator.pop(context, true);
      AppSnackBar.success(context, '✅ Đã thêm lịch tập');
    } else if (mounted) {
      AppSnackBar.error(context, '❌ Thêm lịch tập thất bại');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(title: Text(LocaleKey.addScheduleTitle.tr)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Chọn bài tập
                  Text(
                    'Chọn bài tập',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: TColor.gray.withOpacity(0.3)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ExerciseCategory>(
                        value: _selectedCategory,
                        isExpanded: true,
                        hint: Text(LocaleKey.selectExerciseHint.tr),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.titleEx ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Chọn thời gian
                  Text(
                    'Thời gian',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: TColor.gray.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: TColor.primaryColor1),
                          const SizedBox(width: 12),
                          Text(
                            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Switch bật/tắt thông báo
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: TColor.gray.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications, color: TColor.primaryColor1),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nhắc nhở khi đến giờ',
                            style: TextStyle(color: textColor, fontSize: 14),
                          ),
                        ),
                        Switch(
                          value: _hasNotification,
                          onChanged: (value) {
                            setState(() => _hasNotification = value);
                          },
                          activeThumbColor: TColor.primaryColor1,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Nút thêm lịch
                  RoundButton(title: 'Thêm lịch', onPressed: _save),
                ],
              ),
            ),
    );
  }
}
