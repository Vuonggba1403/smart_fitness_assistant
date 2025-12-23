import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fitness_assistant/core/models/chat_history_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppShared {
  static late SharedPreferences _prefs;
  static const String _languageKey = 'language_code';
  static const String _chatHistoryPrefix = 'chat_history_';
  static const String _workoutPlanPrefix = 'workout_plan_';

  static final _supabase = Supabase.instance.client;

  /// Khởi tạo SharedPreferences (gọi trong main.dart)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Lấy mã ngôn ngữ đã lưu (Sync - không cần await)
  static String? getLanguageCodeSync() {
    return _prefs.getString(_languageKey);
  }

  /// Lấy mã ngôn ngữ đã lưu (Async)
  static Future<String> getLanguageCode() async {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  /// Lưu mã ngôn ngữ
  static Future<void> setLanguageCode(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }

  // ==================== CHAT HISTORY ====================

  /// Lấy key cho chat history của user
  static String _getChatHistoryKey(String userId) {
    return '$_chatHistoryPrefix$userId';
  }

  /// Lưu danh sách chat sessions của user
  static Future<void> saveChatSessions(
    String userId,
    List<ChatSession> sessions,
  ) async {
    final key = _getChatHistoryKey(userId);
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _prefs.setString(key, jsonEncode(jsonList));
  }

  /// Lấy danh sách chat sessions của user
  static Future<List<ChatSession>> getChatSessions(String userId) async {
    final key = _getChatHistoryKey(userId);
    final jsonString = _prefs.getString(key);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => ChatSession.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Thêm một chat session mới
  static Future<void> addChatSession(String userId, ChatSession session) async {
    final sessions = await getChatSessions(userId);
    sessions.insert(0, session); // Thêm vào đầu danh sách
    await saveChatSessions(userId, sessions);
  }

  /// Cập nhật một chat session
  static Future<void> updateChatSession(
    String userId,
    ChatSession updatedSession,
  ) async {
    final sessions = await getChatSessions(userId);
    final index = sessions.indexWhere((s) => s.id == updatedSession.id);

    if (index != -1) {
      sessions[index] = updatedSession;
      await saveChatSessions(userId, sessions);
    }
  }

  /// Xóa một chat session
  static Future<void> deleteChatSession(String userId, String sessionId) async {
    final sessions = await getChatSessions(userId);
    sessions.removeWhere((s) => s.id == sessionId);
    await saveChatSessions(userId, sessions);
  }

  /// Xóa tất cả chat sessions của user
  static Future<void> clearAllChatSessions(String userId) async {
    final key = _getChatHistoryKey(userId);
    await _prefs.remove(key);
  }

  /// Lấy chat session theo ID
  static Future<ChatSession?> getChatSessionById(
    String userId,
    String sessionId,
  ) async {
    final sessions = await getChatSessions(userId);
    try {
      return sessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  /// Lưu chat session lên Supabase (cloud sync)
  static Future<void> saveChatSessionToCloud(
    String userId,
    ChatSession session,
  ) async {
    await _supabase.from('chat_sessions').upsert({
      'user_id': userId,
      'session_id': session.id,
      'title': session.title,
      'created_at': session.createdAt.toIso8601String(),
      'last_message_at': session.lastMessageAt.toIso8601String(),
      'messages': jsonEncode(session.messages.map((m) => m.toJson()).toList()),
    });
  }

  /// Load chat sessions từ Supabase
  static Future<List<ChatSession>> getChatSessionsFromCloud(
    String userId,
  ) async {
    final response = await _supabase
        .from('chat_sessions')
        .select()
        .eq('user_id', userId)
        .order('last_message_at', ascending: false);

    return (response as List).map((json) {
      final messages = (jsonDecode(json['messages']) as List)
          .map((m) => ChatMessageData.fromJson(m))
          .toList();

      return ChatSession(
        id: json['session_id'],
        title: json['title'],
        createdAt: DateTime.parse(json['created_at']),
        lastMessageAt: DateTime.parse(json['last_message_at']),
        messages: messages,
      );
    }).toList();
  }

  // ==================== WORKOUT PLAN ====================

  /// Lấy key cho workout plan của user
  static String _getWorkoutPlanKey(String userId) {
    return '$_workoutPlanPrefix$userId';
  }

  /// Lưu workout plan của user
  static Future<void> saveWorkoutPlan(
    String userId,
    Map<String, dynamic> planJson,
  ) async {
    final key = _getWorkoutPlanKey(userId);
    await _prefs.setString(key, jsonEncode(planJson));
  }

  /// Lấy workout plan của user
  static Future<Map<String, dynamic>?> getWorkoutPlan(String userId) async {
    final key = _getWorkoutPlanKey(userId);
    final jsonString = _prefs.getString(key);

    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Xóa workout plan của user
  static Future<void> deleteWorkoutPlan(String userId) async {
    final key = _getWorkoutPlanKey(userId);
    await _prefs.remove(key);
  }

  /// Kiểm tra user có workout plan hay không
  static Future<bool> hasWorkoutPlan(String userId) async {
    final plan = await getWorkoutPlan(userId);
    return plan != null;
  }

  /// Lưu workout plan lên Supabase (cloud sync - optional)
  static Future<void> saveWorkoutPlanToCloud(
    String userId,
    Map<String, dynamic> planJson,
  ) async {
    await _supabase.from('workout_plans').upsert({
      'user_id': userId,
      'plan_data': planJson,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Load workout plan từ Supabase (cloud sync - optional)
  static Future<Map<String, dynamic>?> getWorkoutPlanFromCloud(
    String userId,
  ) async {
    final response = await _supabase
        .from('workout_plans')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return response['plan_data'] as Map<String, dynamic>?;
  }
}
