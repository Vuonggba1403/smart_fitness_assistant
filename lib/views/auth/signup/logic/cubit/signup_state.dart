part of 'signup_cubit.dart';

@immutable
sealed class SignupState {}

final class SignupInitial extends SignupState {}

final class SignUpSuccess extends SignupState {}

final class SignUpLoading extends SignupState {}

final class SignUpError extends SignupState {
  final String message;
  SignUpError(this.message);
}

final class UserDataLoading extends SignupState {}

final class UserDataSuccess extends SignupState {}

final class UserDataFailure extends SignupState {}

final class GetUserDataLoading extends SignupState {}

final class GetUserDataSuccess extends SignupState {}

final class GetUserDataFailure extends SignupState {}

// Thêm state để lưu thông tin tạm thời
final class UserInfoSaved extends SignupState {
  final Map<String, String> userInfo;
  UserInfoSaved(this.userInfo);
}
