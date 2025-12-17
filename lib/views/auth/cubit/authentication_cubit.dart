import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:smart_fitness_assistant/core/models/user_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(const AuthenticationInitial());
  // Lấy Supabase client toàn cục đã được khởi tạo trong Supabase.initialize()
  SupabaseClient client = Supabase.instance.client;

  //Login function
  Future<void> login({required String email, required String password}) async {
    emit(const LoginLoading());
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
        emit(const LoginSuccess());
      } else {
        log('❌ No user found');
        emit(const LoginError('Login failed'));
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
    emit(const LogoutLoading());
    try {
      await client.auth.signOut();
      emit(const LogoutSuccess());
    } catch (e) {
      emit(LogoutError(e.toString()));
    }
  }

  //forgot password
  Future<void> resetPassword({required String email}) async {
    emit(const PasswordResetLoading());
    try {
      await client.auth.resetPasswordForEmail(email);
      emit(const PasswordResetSuccess());
    } catch (e) {
      log(e.toString());
      emit(PasswordResetError(e.toString()));
    }
  }

  // Lưu thông tin user tạm thời
  Map<String, String> tempUserInfo = {};

  // Initialize userDataModel with empty values
  UserDataModel? userDataModel = UserDataModel(
    userId: '',
    username: '',
    height: '',
    email: '',
    weight: '',
    weight_goal: '',
    your_goals: '',
    age: '',
  );

  // Lưu thông tin cơ bản (email, password, username)
  void saveBasicInfo({
    required String email,
    required String password,
    required String username,
  }) {
    tempUserInfo['email'] = email;
    tempUserInfo['password'] = password;
    tempUserInfo['username'] = username;

    // Initialize userDataModel with basic info
    userDataModel = UserDataModel(
      userId: '',
      username: username,
      email: email,
      height: '',
      weight: '',
      weight_goal: '',
      your_goals: '',
      age: '',
    );

    emit(UserInfoSaved(Map.from(tempUserInfo)));
  }

  // Lưu thông tin profile (height, weight, weight_goal)
  void saveProfileInfo({
    required String height,
    required String weight,
    required String weightGoal,
    required String age,
  }) {
    tempUserInfo['height'] = height;
    tempUserInfo['weight'] = weight;
    tempUserInfo['weight_goal'] = weightGoal;
    tempUserInfo['age'] = age;
    emit(UserInfoSaved(Map.from(tempUserInfo)));

    userDataModel = UserDataModel(
      userId: userDataModel?.userId ?? '',
      username: userDataModel?.username ?? '',
      email: userDataModel?.email ?? '',
      height: height,
      weight: weight,
      weight_goal: weightGoal,
      your_goals: userDataModel?.your_goals ?? '',
      age: age,
    );
  }

  // Lưu goal và thực hiện đăng ký
  Future<void> completeRegistration({required String yourGoals}) async {
    emit(const SignUpLoading());
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
        "age": tempUserInfo['age']!,
      });

      // Xóa thông tin tạm
      tempUserInfo.clear();

      emit(const SignUpSuccess());
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
    emit(const SignUpLoading());
    try {
      await client.auth.signUp(password: password, email: email);
      emit(const SignUpSuccess());
    } on AuthException catch (e) {
      log(e.toString());
      emit(SignUpError(e.message));
    } catch (e) {
      log(e.toString());
      emit(SignUpError(e.toString()));
    }
  }

  // ✅ Sửa tên method theo chuẩn Dart (camelCase)
  @Deprecated('Use completeRegistration instead')
  Future<void> userData({
    required String email,
    required String password,
    required String username,
    required String height,
    required String weight,
    required String weight_goal,
    required String your_goals,
  }) async {
    emit(const UserDataLoading());
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
      emit(const UserDataSuccess());
    } catch (e) {
      emit(const UserDataFailure());
    }
  }

  //get User Data
  Future<void> getUserData() async {
    emit(const GetUserDataLoading());
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
        age: data[0]['age'],
      );
      emit(const GetUserDataSuccess());
    } catch (e) {
      log(e.toString());
      emit(const GetUserDataError());
    }
  }

  /// ✅ Tính BMR (Basal Metabolic Rate)
  /// BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age + 5
  double calculateBMR({
    required double weight,
    required double height,
    required int age,
  }) {
    return (10 * weight) + (6.25 * height) - (5 * age) + 5;
  }

  /// ✅ Tính TDEE (Total Daily Energy Expenditure)
  /// TDEE = BMR × activity_factor
  double calculateTDEE({required double bmr, required double activityFactor}) {
    return bmr * activityFactor;
  }

  /// ✅ Lấy calo hàng ngày từ userModel
  /// Returns: (bmr, tdee) tuple
  Map<String, double> getDailyCalories({required double activityFactor}) {
    if (userDataModel == null) {
      return {'bmr': 0, 'tdee': 0};
    }

    final weight = double.tryParse(userDataModel!.weight) ?? 0;
    final height = double.tryParse(userDataModel!.height) ?? 0;
    final age = int.tryParse(userDataModel!.age) ?? 0;

    final bmr = calculateBMR(weight: weight, height: height, age: age);
    final tdee = calculateTDEE(bmr: bmr, activityFactor: activityFactor);

    return {'bmr': bmr, 'tdee': tdee};
  }

  /// ✅ Xóa tài khoản user và tất cả dữ liệu liên quan
  /// Trigger sẽ tự động xóa auth.users
  Future<void> deleteAccount() async {
    emit(const DeleteAccountLoading());
    try {
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        emit(const DeleteAccountError('Bạn chưa đăng nhập'));
        return;
      }

      log('🗑️ Deleting account for user: $userId');

      // Gọi RPC function thay vì xóa trực tiếp
      await client.rpc('delete_user_account');

      log('✅ User deleted via RPC function');

      // Sign out
      await client.auth.signOut();

      // Clear data
      userDataModel = null;
      tempUserInfo.clear();

      emit(const DeleteAccountSuccess());
    } catch (e) {
      log('❌ Delete Account Error: $e');
      emit(DeleteAccountError('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }
}
