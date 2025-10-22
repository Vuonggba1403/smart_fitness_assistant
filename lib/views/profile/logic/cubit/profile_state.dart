part of 'profile_cubit.dart';

@immutable
class ProfileState {
  final bool isNotificationEnabled;
  final bool isDarkMode;

  const ProfileState({
    required this.isNotificationEnabled,
    required this.isDarkMode,
  });

  ProfileState copyWith({bool? isNotificationEnabled, bool? isDarkMode}) {
    return ProfileState(
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
