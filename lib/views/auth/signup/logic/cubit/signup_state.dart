part of 'signup_cubit.dart';

@immutable
class SignUpState {
  final bool isChecked;

  const SignUpState({this.isChecked = false});

  SignUpState copyWith({bool? isChecked}) {
    return SignUpState(isChecked: isChecked ?? this.isChecked);
  }
}
