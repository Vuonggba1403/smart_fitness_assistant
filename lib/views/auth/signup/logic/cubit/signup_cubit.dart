import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smart_fitness_assistant/core/models/user_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());
  // Lấy Supabase client toàn cục đã được khởi tạo trong Supabase.initialize()
  SupabaseClient client = Supabase.instance.client;

  // Lưu thông tin user tạm thời
  Map<String, String> tempUserInfo = {};

  // Lưu thông tin cơ bản (email, password, username)
  void saveBasicInfo({
    required String email,
    required String password,
    required String username,
  }) {
    tempUserInfo['email'] = email;
    tempUserInfo['password'] = password;
    tempUserInfo['username'] = username;
    emit(UserInfoSaved(Map.from(tempUserInfo)));
  }

  // Lưu thông tin profile (height, weight, weight_goal)
  void saveProfileInfo({
    required String height,
    required String weight,
    required String weightGoal,
  }) {
    tempUserInfo['height'] = height;
    tempUserInfo['weight'] = weight;
    tempUserInfo['weight_goal'] = weightGoal;
    emit(UserInfoSaved(Map.from(tempUserInfo)));
  }

  // Lưu goal và thực hiện đăng ký
  Future<void> completeRegistration({required String yourGoals}) async {
    emit(SignUpLoading());
    try {
      tempUserInfo['your_goals'] = yourGoals;

      // Bước 1: Đăng ký tài khoản
      await client.auth.signUp(
        password: tempUserInfo['password']!,
        email: tempUserInfo['email']!,
      );

      // Bước 2: Lưu thông tin user vào database
      await client.from('user').upsert({
        "id": client.auth.currentUser!.id,
        "username": tempUserInfo['username']!,
        "email": tempUserInfo['email']!,
        "height": tempUserInfo['height']!,
        "weight": tempUserInfo['weight']!,
        "weight_goal": tempUserInfo['weight_goal']!,
        "your_goals": tempUserInfo['your_goals']!,
      });

      // Xóa thông tin tạm
      tempUserInfo.clear();

      emit(SignUpSuccess());
    } on AuthException catch (e) {
      log(e.toString());
      emit(SignUpError(e.message));
    } catch (e) {
      log(e.toString());
      emit(SignUpError(e.toString()));
    }
  }

  // Deprecated: Giữ lại để tương thích ngược
  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String height,
    required String weight,
    required String weight_goal,
    required String your_goals,
  }) async {
    emit(SignUpLoading());
    try {
      await client.auth.signUp(password: password, email: email);
      emit(SignUpSuccess());
    } on AuthException catch (e) {
      log(e.toString());
      emit(SignUpError(e.message));
    } catch (e) {
      log(e.toString());
      emit(SignUpError(e.toString()));
    }
  }

  // Deprecated: Sử dụng completeRegistration thay thế
  Future<void> UserData({
    required String email,
    required String password,
    required String username,
    required String height,
    required String weight,
    required String weight_goal,
    required String your_goals,
  }) async {
    emit(UserDataLoading());
    try {
      //insert => only add
      //update => update or add
      await client.from('user').upsert({
        "id": client.auth.currentUser!.id,
        "username": username,
        "email": email,
        "height": height,
        "weight": weight,
        "weight_goal": weight_goal,
        "your_goals": your_goals,
      });
      emit(UserDataSuccess());
    } catch (e) {
      // print(e);
      emit(UserDataFailure());
    }
  }

  //get User Data
  UserDataModel? userDataModel;
  Future<void> getUserData() async {
    emit(GetUserDataLoading());
    try {
      final data = await client
          .from('user')
          .select()
          .eq("id", client.auth.currentUser!.id);
      // log(data.toString());
      userDataModel = UserDataModel(
        userId: data[0]['id'],
        username: data[0]['username'],
        height: data[0]['height'],
        email: data[0]['email'],
        weight: data[0]['weight'],
        weight_goal: data[0]['weight_goal'],
        your_goals: data[0]['your_goals'],
      );
      emit(GetUserDataSuccess());
    } catch (e) {
      log(e.toString());
      emit(GetUserDataFailure());
    }
  }
}
