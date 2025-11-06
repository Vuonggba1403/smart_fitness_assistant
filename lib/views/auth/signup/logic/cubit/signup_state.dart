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
