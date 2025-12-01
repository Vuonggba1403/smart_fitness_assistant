class WorkoutSet {
  final int setNumber;
  final double weight;
  final int reps;
  bool isCompleted;

  WorkoutSet({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });

  WorkoutSet copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    bool? isCompleted,
  }) {
    return WorkoutSet(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
