part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<int> showingTooltipOnSpots;
  final List<Map<String, dynamic>> lastWorkoutArr;
  final List<Map<String, dynamic>> waterArr;
  final String currentLanguage;

  HomeLoaded({
    required this.showingTooltipOnSpots,
    required this.lastWorkoutArr,
    required this.waterArr,
    this.currentLanguage = 'en',
  });

  HomeLoaded copyWith({
    List<int>? showingTooltipOnSpots,
    List<Map<String, dynamic>>? lastWorkoutArr,
    List<Map<String, dynamic>>? waterArr,
    String? currentLanguage,
  }) {
    return HomeLoaded(
      showingTooltipOnSpots:
          showingTooltipOnSpots ?? this.showingTooltipOnSpots,
      lastWorkoutArr: lastWorkoutArr ?? this.lastWorkoutArr,
      waterArr: waterArr ?? this.waterArr,
      currentLanguage: currentLanguage ?? this.currentLanguage,
    );
  }
}
