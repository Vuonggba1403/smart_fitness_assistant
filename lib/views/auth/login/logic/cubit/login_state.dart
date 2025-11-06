part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

final class LoginSuccess extends LoginState {}

// Password Reset States
final class PasswordResetLoading extends LoginState {}

final class PasswordResetSuccess extends LoginState {}

final class PasswordResetError extends LoginState {
  final String message;
  PasswordResetError(this.message);
}

//Logout State
final class LogoutLoading extends LoginState {}

final class LogoutSuccess extends LoginState {}

final class LogoutError extends LoginState {
  final String message;
  LogoutError(this.message);
}
