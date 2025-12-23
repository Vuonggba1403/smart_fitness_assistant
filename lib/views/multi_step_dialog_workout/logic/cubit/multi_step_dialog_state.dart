part of 'multi_step_dialog_cubit.dart';

/// State cho multi-step dialog
class MultiStepDialogState {
  final int currentStep;
  final bool isLoadingData;

  // Step 1: Activity Level
  final ActivityLevel? selectedActivityLevel;

  // Step 2: Fitness Level
  final String? selectedFitnessLevel;

  // Step 3: Equipment
  final String? selectedEquipment;

  // Step 4: Dietary Preferences
  final Set<String> selectedDietaryPreferences;

  // Step 5: Food Allergies
  final Set<Meal> selectedFoodAllergies;
  final List<Meal> allMeals;
  final List<Meal> filteredMeals;

  // Step 6: Injuries
  final Set<Injury> selectedInjuries;
  final List<Injury> allInjuries;
  final List<Injury> filteredInjuries;

  const MultiStepDialogState({
    this.currentStep = 0,
    this.isLoadingData = false,
    this.selectedActivityLevel,
    this.selectedFitnessLevel,
    this.selectedEquipment,
    this.selectedDietaryPreferences = const {},
    this.selectedFoodAllergies = const {},
    this.allMeals = const [],
    this.filteredMeals = const [],
    this.selectedInjuries = const {},
    this.allInjuries = const [],
    this.filteredInjuries = const [],
  });

  /// Copy state với các giá trị mới
  MultiStepDialogState copyWith({
    int? currentStep,
    bool? isLoadingData,
    ActivityLevel? selectedActivityLevel,
    String? selectedFitnessLevel,
    String? selectedEquipment,
    Set<String>? selectedDietaryPreferences,
    Set<Meal>? selectedFoodAllergies,
    List<Meal>? allMeals,
    List<Meal>? filteredMeals,
    Set<Injury>? selectedInjuries,
    List<Injury>? allInjuries,
    List<Injury>? filteredInjuries,
  }) {
    return MultiStepDialogState(
      currentStep: currentStep ?? this.currentStep,
      isLoadingData: isLoadingData ?? this.isLoadingData,
      selectedActivityLevel:
          selectedActivityLevel ?? this.selectedActivityLevel,
      selectedFitnessLevel: selectedFitnessLevel ?? this.selectedFitnessLevel,
      selectedEquipment: selectedEquipment ?? this.selectedEquipment,
      selectedDietaryPreferences:
          selectedDietaryPreferences ?? this.selectedDietaryPreferences,
      selectedFoodAllergies:
          selectedFoodAllergies ?? this.selectedFoodAllergies,
      allMeals: allMeals ?? this.allMeals,
      filteredMeals: filteredMeals ?? this.filteredMeals,
      selectedInjuries: selectedInjuries ?? this.selectedInjuries,
      allInjuries: allInjuries ?? this.allInjuries,
      filteredInjuries: filteredInjuries ?? this.filteredInjuries,
    );
  }
}
