import 'dart:developer';
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
      log('🔐 Attempting login for: $email');

      //Gui yeu cau dang nhap
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      log('✅ Login response: ${response.user?.id}');

      // ✅ QUAN TRỌNG: Phải emit LoginSuccess
      if (response.user != null) {
        log('✅ Login successful, emitting LoginSuccess');
        emit(LoginSuccess());
      } else {
        log('❌ No user found');
        emit(LoginError('Login failed'));
      }
    } on AuthException catch (e) {
      log('❌ Auth Error: ${e.message}');
      emit(LoginError(e.message));
    } catch (e) {
      log('❌ Login Error: $e');
      emit(LoginError(e.toString()));
    }
  }

  //logout
  Future<void> signOut() async {
    emit(LogoutLoading());
    try {
      await client.auth.signOut();
      emit(LogoutSuccess());
    } catch (e) {
      emit(LogoutError(e.toString()));
    }
  }

  //forgot password
  Future<void> resetPassword({required String email}) async {
    emit(PasswordResetLoading());
    try {
      await client.auth.resetPasswordForEmail(email);
      emit(PasswordResetSuccess());
    } catch (e) {
      log(e.toString());
      emit(PasswordResetError(e.toString()));
    }
  }
}
