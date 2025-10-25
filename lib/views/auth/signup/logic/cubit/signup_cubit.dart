import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'signup_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(const SignUpState());

  /// 🟢 Hàm toggle checkbox
  void toggleCheck() {
    emit(state.copyWith(isChecked: !state.isChecked));
  }

  /// 🟢 Nếu muốn reset sau khi đăng ký xong
  void reset() {
    emit(const SignUpState());
  }
}
