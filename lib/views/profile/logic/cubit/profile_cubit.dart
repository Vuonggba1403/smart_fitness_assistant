import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit()
    : super(ProfileState(isNotificationEnabled: false, isDarkMode: false)) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isNotificationEnabled =
        prefs.getBool('isNotificationEnabled') ?? false;
    emit(
      ProfileState(
        isNotificationEnabled: isNotificationEnabled,
        isDarkMode: false, 
      ),
    );
  }

  void toggleNotification(bool value) async {
    emit(state.copyWith(isNotificationEnabled: value));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationEnabled', value);
  }

  void toggleDarkMode(bool value) async {
    emit(state.copyWith(isDarkMode: value));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }
}
