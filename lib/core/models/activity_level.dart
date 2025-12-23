class ActivityLevel {
  final String id;
  final String title;
  final String description;
  final double activityFactor;
  final int number;
  final String? icon;

  ActivityLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.activityFactor,
    required this.number,
    this.icon,
  });

  factory ActivityLevel.fromJson(Map<String, dynamic> json) {
    return ActivityLevel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      activityFactor: (json['activity_factor'] as num).toDouble(),
      number: json['number'] as int,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'activity_factor': activityFactor,
      'number': number,
      'icon': icon,
    };
  }
}
