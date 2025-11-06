import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationInitial());

  var client = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      //Gui yeu cau dang nhap
      await client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      emit(LoginError(e.message));
      return;
    } catch (e) {
      emit(LoginError(e.toString()));
      return;
    }
  }
}
