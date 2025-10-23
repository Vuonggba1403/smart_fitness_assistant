// profile_state.dart (part of profile_cubit.dart)
part of 'profile_cubit.dart';

@immutable
class ProfileState {
  final bool isNotificationEnabled;

  const ProfileState({required this.isNotificationEnabled});

  ProfileState copyWith({bool? isNotificationEnabled}) {
    return ProfileState(
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }
}
