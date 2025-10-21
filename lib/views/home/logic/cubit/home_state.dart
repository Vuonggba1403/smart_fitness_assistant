part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<int> showingTooltipOnSpots;
  final List<Map<String, dynamic>> lastWorkoutArr;
  final List<Map<String, dynamic>> waterArr;

  HomeLoaded({
    required this.showingTooltipOnSpots,
    required this.lastWorkoutArr,
    required this.waterArr,
  });

  HomeLoaded copyWith({
    List<int>? showingTooltipOnSpots,
    List<Map<String, dynamic>>? lastWorkoutArr,
    List<Map<String, dynamic>>? waterArr,
  }) {
    return HomeLoaded(
      showingTooltipOnSpots:
          showingTooltipOnSpots ?? this.showingTooltipOnSpots,
      lastWorkoutArr: lastWorkoutArr ?? this.lastWorkoutArr,
      waterArr: waterArr ?? this.waterArr,
    );
  }
}
