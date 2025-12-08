import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/models/scheduled_workout.dart';
import 'package:smart_fitness_assistant/core/models/exercise_category.dart';
import 'package:smart_fitness_assistant/core/widgets/round_button.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;

  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();

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

  Future<void> _loadCategories() async {
    try {
      final response = await _supabase
          .from('exercise_categories')
          .select()
          .order('title_ex');

      _categories = response
          .map((json) => ExerciseCategory.fromJson(json))
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading categories: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _save() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn bài tập')));
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

    // ✅ Check thời gian phải trong tương lai
    if (scheduledTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn thời gian trong tương lai'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final schedule = ScheduledWorkout(
      forUser: userId,
      categoryId: _selectedCategory!.id!,
      categoryName: _selectedCategory!.titleEx!,
      imageUrl: _selectedCategory!.imgUrl ?? '',
      scheduledTime: scheduledTime,
      hasNotification: _hasNotification,
    );

    try {
      final response = await _supabase
          .from('scheduled_workouts')
          .insert(schedule.toJson())
          .select()
          .single();

      final newSchedule = ScheduledWorkout.fromJson(response);

      print('✅ Schedule inserted: ${newSchedule.id}');
      print('   Category: ${newSchedule.categoryName}');
      print('   Time: ${newSchedule.scheduledTime}');
      print('   Notification: ${newSchedule.hasNotification}');

      // ✅ Lên lịch notification nếu cần
      if (_hasNotification) {
        await _notificationService.scheduleWorkoutNotification(
          id: newSchedule.id.hashCode,
          title: '⏰ Đã đến giờ tập luyện!',
          body: '${newSchedule.categoryName} - Bắt đầu ngay thôi! 💪',
          scheduledTime: scheduledTime,
        );
        print('✅ Notification scheduled');
      }

      if (mounted) {
        // ✅ Pop với result = true
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã thêm lịch tập'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm lịch tập')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        hint: const Text('Chọn bài tập'),
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
                          activeColor: TColor.primaryColor1,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  RoundButton(title: 'Thêm lịch', onPressed: _save),
                ],
              ),
            ),
    );
  }
}
