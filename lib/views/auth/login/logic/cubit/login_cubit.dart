import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  // Lấy Supabase client toàn cục đã được khởi tạo trong Supabase.initialize()
  SupabaseClient client = Supabase.instance.client;

  //Login function
  Future<void> login({required String email, required String password}) async {
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
