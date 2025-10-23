// profile_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_state.dart';

/// ProfileCubit chỉ quản lý profile-specific settings (ví dụ notification).
/// Không chứa isDarkMode vì ThemeCubit đã quản lý toàn app.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState(isNotificationEnabled: false)) {
    _loadSettings();
  }

  /// Load các cài đặt profile từ SharedPreferences (hiện chỉ có notification).
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isNotificationEnabled =
        prefs.getBool('isNotificationEnabled') ?? false;
    emit(ProfileState(isNotificationEnabled: isNotificationEnabled));
  }

  /// Toggle trạng thái thông báo, lưu vào prefs và emit state mới.
  Future<void> toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationEnabled', value);
    emit(state.copyWith(isNotificationEnabled: value));
  }
}
