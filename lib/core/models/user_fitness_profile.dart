/// Model chứa thông tin bổ sung cho việc tạo workout plan
class UserFitnessProfile {
  final String fitnessLevel; // 'beginner', 'intermediate', 'advanced'
  final String equipment; // 'gym', 'home', 'mixed'
  final List<String>
  dietaryPreferences; // ['vegetarian', 'halal', 'vegan', ...]
  final List<String> foodAllergies; // ['peanut', 'shellfish', 'dairy', ...]
  final List<String> injuries; // ['back_pain', 'knee_issues', 'shoulder', ...]

  const UserFitnessProfile({
    required this.fitnessLevel,
    required this.equipment,
    this.dietaryPreferences = const [],
    this.foodAllergies = const [],
    this.injuries = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'fitness_level': fitnessLevel,
      'equipment': equipment,
      'dietary_preferences': dietaryPreferences,
      'food_allergies': foodAllergies,
      'injuries': injuries,
    };
  }

  factory UserFitnessProfile.fromJson(Map<String, dynamic> json) {
    return UserFitnessProfile(
      fitnessLevel: json['fitness_level'] as String,
      equipment: json['equipment'] as String,
      dietaryPreferences: List<String>.from(json['dietary_preferences'] ?? []),
      foodAllergies: List<String>.from(json['food_allergies'] ?? []),
      injuries: List<String>.from(json['injuries'] ?? []),
    );
  }

  /// Chuyển thành string để gửi cho AI
  String toPromptString() {
    final buffer = StringBuffer();

    buffer.writeln('User Fitness Profile:');
    buffer.writeln('- Fitness Level: ${_getFitnessLevelLabel()}');
    buffer.writeln('- Equipment Access: ${_getEquipmentLabel()}');

    if (dietaryPreferences.isNotEmpty) {
      buffer.writeln('- Dietary Preferences: ${dietaryPreferences.join(", ")}');
    }

    if (foodAllergies.isNotEmpty) {
      buffer.writeln('- Food Allergies: ${foodAllergies.join(", ")}');
    }

    if (injuries.isNotEmpty) {
      buffer.writeln('- Injury History: ${injuries.join(", ")}');
    }

    return buffer.toString();
  }

  String _getFitnessLevelLabel() {
    switch (fitnessLevel) {
      case 'beginner':
        return 'Beginner (0-6 months experience)';
      case 'intermediate':
        return 'Intermediate (6-24 months experience)';
      case 'advanced':
        return 'Advanced (2+ years experience)';
      default:
        return fitnessLevel;
    }
  }

  String _getEquipmentLabel() {
    switch (equipment) {
      case 'gym':
        return 'Full Gym Access';
      case 'home':
        return 'Home Workout (Minimal Equipment)';
      case 'mixed':
        return 'Mixed (Gym + Home)';
      default:
        return equipment;
    }
  }
}
