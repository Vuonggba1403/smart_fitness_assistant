part of 'authentication_cubit.dart';

@immutable
sealed class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

final class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

final class LoginLoading extends AuthenticationState {
  const LoginLoading();
}

final class LoginError extends AuthenticationState {
  final String message;
  const LoginError(this.message);

  @override
  List<Object?> get props => [message];
}

final class LoginSuccess extends AuthenticationState {
  const LoginSuccess();
}

// Password Reset States
final class PasswordResetLoading extends AuthenticationState {
  const PasswordResetLoading();
}

final class PasswordResetSuccess extends AuthenticationState {
  const PasswordResetSuccess();
}

final class PasswordResetError extends AuthenticationState {
  final String message;
  const PasswordResetError(this.message);

  @override
  List<Object?> get props => [message];
}

//Logout State
final class LogoutLoading extends AuthenticationState {
  const LogoutLoading();
}

final class LogoutSuccess extends AuthenticationState {
  const LogoutSuccess();
}

final class LogoutError extends AuthenticationState {
  final String message;
  const LogoutError(this.message);

  @override
  List<Object?> get props => [message];
}

// Signup States
final class SignUpSuccess extends AuthenticationState {
  const SignUpSuccess();
}

final class SignUpLoading extends AuthenticationState {
  const SignUpLoading();
}

final class SignUpError extends AuthenticationState {
  final String message;
  const SignUpError(this.message);

  @override
  List<Object?> get props => [message];
}

final class UserDataLoading extends AuthenticationState {
  const UserDataLoading();
}

final class UserDataSuccess extends AuthenticationState {
  const UserDataSuccess();
}

final class UserDataFailure extends AuthenticationState {
  const UserDataFailure();
}

final class GetUserDataLoading extends AuthenticationState {
  const GetUserDataLoading();
}

final class GetUserDataSuccess extends AuthenticationState {
  const GetUserDataSuccess();
}

final class GetUserDataError extends AuthenticationState {
  const GetUserDataError();
}

final class UserInfoSaved extends AuthenticationState {
  final Map<String, String> userInfo;
  const UserInfoSaved(this.userInfo);

  @override
  List<Object?> get props => [userInfo];
}

// Delete Account States
final class DeleteAccountLoading extends AuthenticationState {
  const DeleteAccountLoading();
}

final class DeleteAccountSuccess extends AuthenticationState {
  const DeleteAccountSuccess();
}

final class DeleteAccountError extends AuthenticationState {
  final String message;
  const DeleteAccountError(this.message);

  @override
  List<Object?> get props => [message];
}
