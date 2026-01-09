import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:smart_fitness_assistant/core/models/activity_level.dart';
import 'package:smart_fitness_assistant/core/models/injury.dart';
import 'package:smart_fitness_assistant/core/models/meal.dart';
import 'package:smart_fitness_assistant/core/models/user_fitness_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'multi_step_dialog_state.dart';

/// Cubit quản lý multi-step dialog cho workout plan generation
class MultiStepDialogCubit extends Cubit<MultiStepDialogState> {
  MultiStepDialogCubit() : super(const MultiStepDialogState()) {
    _loadInitialData();
  }

  /// Load dữ liệu ban đầu (meals và injuries)
  Future<void> _loadInitialData() async {
    emit(state.copyWith(isLoadingData: true));
    await Future.wait([_loadMeals(), _loadInjuries()]);
    emit(state.copyWith(isLoadingData: false));
  }

  /// Load danh sách meals từ Supabase
  Future<void> _loadMeals() async {
    try {
      final response = await Supabase.instance.client
          .from('meals')
          .select('*, name_en, description_en')
          .eq('is_verified', true)
          .order('name', ascending: true);

      final meals = (response as List)
          .map((json) => Meal.fromJson(json))
          .toList();
      emit(state.copyWith(allMeals: meals, filteredMeals: meals));
    } catch (_) {
      emit(state.copyWith(allMeals: [], filteredMeals: []));
    }
  }

  /// Load danh sách injuries từ JSON
  Future<void> _loadInjuries() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/injuries.json',
      );
      final jsonData = json.decode(jsonString) as List;
      final injuries = jsonData.map((json) => Injury.fromJson(json)).toList();

      injuries.sort((a, b) {
        final catCompare = a.category.compareTo(b.category);
        return catCompare != 0 ? catCompare : a.name.compareTo(b.name);
      });

      emit(state.copyWith(allInjuries: injuries, filteredInjuries: injuries));
    } catch (_) {
      emit(state.copyWith(allInjuries: [], filteredInjuries: []));
    }
  }

  /// Chuyển sang bước tiếp theo
  void nextStep() {
    if (state.currentStep < 5) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  /// Quay lại bước trước
  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  /// Chọn activity level
  void selectActivityLevel(ActivityLevel level) {
    emit(state.copyWith(selectedActivityLevel: level));
  }

  /// Chọn fitness level
  void selectFitnessLevel(String level) {
    emit(state.copyWith(selectedFitnessLevel: level));
  }

  /// Chọn equipment
  void selectEquipment(String equipment) {
    emit(state.copyWith(selectedEquipment: equipment));
  }

  /// Toggle dietary preference
  void toggleDietaryPreference(String preference) {
    final updated = Set<String>.from(state.selectedDietaryPreferences);
    updated.contains(preference)
        ? updated.remove(preference)
        : updated.add(preference);
    emit(state.copyWith(selectedDietaryPreferences: updated));
  }

  /// Clear tất cả dietary preferences
  void clearDietaryPreferences() {
    emit(state.copyWith(selectedDietaryPreferences: {}));
  }

  /// Toggle food allergy (meal)
  void toggleFoodAllergy(Meal meal) {
    final updated = Set<Meal>.from(state.selectedFoodAllergies);
    updated.contains(meal) ? updated.remove(meal) : updated.add(meal);
    emit(state.copyWith(selectedFoodAllergies: updated));
  }

  /// Clear tất cả food allergies
  void clearFoodAllergies() {
    emit(state.copyWith(selectedFoodAllergies: {}));
  }

  /// Filter meals theo search query
  void filterMeals(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(filteredMeals: state.allMeals));
    } else {
      final filtered = state.allMeals
          .where(
            (meal) => meal.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      emit(state.copyWith(filteredMeals: filtered));
    }
  }

  /// Toggle injury
  void toggleInjury(Injury injury) {
    final updated = Set<Injury>.from(state.selectedInjuries);
    updated.contains(injury) ? updated.remove(injury) : updated.add(injury);
    emit(state.copyWith(selectedInjuries: updated));
  }

  /// Clear tất cả injuries
  void clearInjuries() {
    emit(state.copyWith(selectedInjuries: {}));
  }

  /// Filter injuries theo search query
  void filterInjuries(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(filteredInjuries: state.allInjuries));
    } else {
      final filtered = state.allInjuries.where((injury) {
        final nameLower = injury.name.toLowerCase();
        final nameEnLower = injury.nameEn.toLowerCase();
        final categoryLower = injury.category.toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower) ||
            nameEnLower.contains(queryLower) ||
            categoryLower.contains(queryLower);
      }).toList();
      emit(state.copyWith(filteredInjuries: filtered));
    }
  }

  /// Kiểm tra có thể proceed không
  bool canProceed() {
    switch (state.currentStep) {
      case 0:
        return state.selectedActivityLevel != null;
      case 1:
        return state.selectedFitnessLevel != null;
      case 2:
        return state.selectedEquipment != null;
      default:
        return true;
    }
  }

  /// Kiểm tra có thể complete không
  bool canComplete() {
    return state.selectedActivityLevel != null &&
        state.selectedFitnessLevel != null &&
        state.selectedEquipment != null;
  }

  /// Build UserFitnessProfile từ state hiện tại
  UserFitnessProfile buildFitnessProfile() {
    return UserFitnessProfile(
      fitnessLevel: state.selectedFitnessLevel!,
      equipment: state.selectedEquipment!,
      dietaryPreferences: state.selectedDietaryPreferences.toList(),
      foodAllergies: state.selectedFoodAllergies.map((m) => m.name).toList(),
      injuries: state.selectedInjuries.map((i) => i.name).toList(),
    );
  }
}
