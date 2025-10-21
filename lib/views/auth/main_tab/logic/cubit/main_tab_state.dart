part of 'main_tab_cubit.dart';

@immutable
sealed class MainTabState {}

final class MainTabInitial extends MainTabState {}

final class IndexChanged extends MainTabState {}
