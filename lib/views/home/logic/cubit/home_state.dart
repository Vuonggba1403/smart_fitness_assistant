part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<int> showingTooltipOnSpots;
  final List<Map<String, dynamic>> lastWorkoutArr;

  final String currentLanguage;

  HomeLoaded({
    required this.showingTooltipOnSpots,
    required this.lastWorkoutArr,

    this.currentLanguage = 'en',
  });

  HomeLoaded copyWith({
    List<int>? showingTooltipOnSpots,
    List<Map<String, dynamic>>? lastWorkoutArr,
    String? currentLanguage,
  }) {
    return HomeLoaded(
      showingTooltipOnSpots:
          showingTooltipOnSpots ?? this.showingTooltipOnSpots,
      lastWorkoutArr: lastWorkoutArr ?? this.lastWorkoutArr,
      currentLanguage: currentLanguage ?? this.currentLanguage,
    );
  }
}

final class LanguageChanged extends HomeState {
  final String newLanguage;
  LanguageChanged(this.newLanguage);
}
