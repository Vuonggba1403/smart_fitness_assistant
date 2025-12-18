import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:meta/meta.dart';
import 'package:smart_fitness_assistant/core/functions/app_shared.dart';
import 'package:smart_fitness_assistant/views/chatbot/logic/models/chat_history_model.dart';
import 'package:uuid/uuid.dart';

part 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final Gemini _gemini = Gemini.instance;
  final String userId;
  List<ChatMessage> _messages = [];
  String? _currentSessionId;
  DateTime? _sessionCreatedDate; // Theo dõi ngày tạo session

  final ChatUser botUser = ChatUser(id: "bot", firstName: "Fitness Assistant");

  late final ChatUser currentUser;

  ChatbotCubit({required this.userId, String? username})
    : super(ChatbotInitial()) {
    currentUser = ChatUser(id: "user", firstName: username ?? "You");
    _checkAndInitializeChat();
  }

  /// Kiểm tra và khởi tạo chat (check ngày mới)
  Future<void> _checkAndInitializeChat() async {
    // Load session gần nhất
    final sessions = await AppShared.getChatSessions(userId);

    if (sessions.isEmpty) {
      // Chưa có session nào, tạo mới
      await _initializeChat(showWelcome: true);
      return;
    }

    final latestSession = sessions.first;
    final today = DateTime.now();
    final sessionDate = latestSession.createdAt;

    // Kiểm tra nếu session cũ là hôm nay
    final isSameDay =
        today.year == sessionDate.year &&
        today.month == sessionDate.month &&
        today.day == sessionDate.day;

    if (isSameDay) {
      // Load session hiện tại
      await loadChatSession(latestSession.id, keepHistory: true);
    } else {
      // Qua ngày mới, tạo session mới
      await _initializeChat(showWelcome: true);
    }
  }

  /// Khởi tạo chat với tin nhắn chào mừng (delay 1.5s)
  Future<void> _initializeChat({bool showWelcome = true}) async {
    // Tạo session ID mới
    _currentSessionId = const Uuid().v4();
    _sessionCreatedDate = DateTime.now();

    if (showWelcome) {
      // Emit empty state trước
      _messages = [];
      emit(ChatbotLoaded(_messages));

      // Delay 1.5 giây trước khi hiển thị welcome message
      await Future.delayed(const Duration(milliseconds: 1500));

      // Tạo welcome message
      final welcomeMessage = ChatMessage(
        user: botUser,
        createdAt: DateTime.now(),
        text: "Hello, I'm Fitness assistant,\nHow can I help you?",
      );

      _messages = [welcomeMessage];
      emit(ChatbotLoaded(_messages));
    } else {
      _messages = [];
      emit(ChatbotLoaded(_messages));
    }
  }

  /// Gửi tin nhắn từ người dùng
  Future<void> sendMessage(ChatMessage message) async {
    try {
      // Thêm tin nhắn người dùng vào danh sách
      _messages = [message, ..._messages];
      emit(ChatbotResponding(_messages));

      // Tạo tin nhắn bot trống ngay lập tức
      final botMessage = ChatMessage(
        user: botUser,
        createdAt: DateTime.now(),
        text: "",
      );

      // Thêm tin nhắn bot trống vào danh sách
      _messages = [botMessage, ..._messages];
      emit(ChatbotResponding(_messages));

      // Gọi API Gemini để lấy phản hồi
      await _getGeminiResponse(message.text);
    } catch (e) {
      emit(
        ChatbotError(
          "Đã xảy ra lỗi khi gửi tin nhắn. Vui lòng thử lại.",
          _messages,
        ),
      );
    }
  }

  /// Lấy phản hồi từ Gemini API
  Future<void> _getGeminiResponse(String userMessage) async {
    try {
      StringBuffer responseBuffer = StringBuffer();

      // Stream phản hồi từ Gemini
      _gemini
          .streamGenerateContent(userMessage)
          .listen(
            (event) {
              final response = event.output ?? "";
              responseBuffer.write(response);

              // Cập nhật tin nhắn bot đầu tiên (tin nhắn mới nhất)
              _messages[0] = ChatMessage(
                user: botUser,
                createdAt: _messages[0].createdAt,
                text: responseBuffer.toString(),
              );

              emit(ChatbotResponding(List.from(_messages)));
            },
            onError: (error) {
              emit(
                ChatbotError(
                  "Không thể kết nối với trợ lý AI. Vui lòng thử lại sau.",
                  _messages,
                ),
              );
            },
            onDone: () async {
              // Hoàn thành việc nhận phản hồi
              emit(ChatbotLoaded(List.from(_messages)));

              // Lưu chat session sau khi có phản hồi
              await _saveChatSession();
            },
          );
    } catch (e) {
      emit(ChatbotError("Đã xảy ra lỗi khi xử lý phản hồi.", _messages));
    }
  }

  /// Lưu chat session hiện tại
  Future<void> _saveChatSession() async {
    try {
      if (_currentSessionId == null || _messages.length <= 1) return;

      // Tạo title từ tin nhắn đầu tiên của user
      String title = "New Chat";
      final userMessages = _messages
          .where((m) => m.user.id == currentUser.id)
          .toList();
      if (userMessages.isNotEmpty) {
        final firstUserMessage = userMessages.last.text;
        title = firstUserMessage.length > 30
            ? '${firstUserMessage.substring(0, 30)}...'
            : firstUserMessage;
      }

      // Chuyển đổi ChatMessage sang ChatMessageData
      final messageDataList = _messages.reversed.map((msg) {
        return ChatMessageData(
          userId: msg.user.id,
          userName: msg.user.firstName ?? '',
          text: msg.text,
          createdAt: msg.createdAt,
          isBot: msg.user.id == botUser.id,
        );
      }).toList();

      // Kiểm tra session đã tồn tại chưa
      final existingSession = await AppShared.getChatSessionById(
        userId,
        _currentSessionId!,
      );

      if (existingSession != null) {
        // Cập nhật session hiện có
        final updatedSession = existingSession.copyWith(
          title: title, // Cập nhật title mới nhất
          lastMessageAt: DateTime.now(),
          messages: messageDataList,
        );
        await AppShared.updateChatSession(userId, updatedSession);
      } else {
        // Tạo session mới
        final newSession = ChatSession(
          id: _currentSessionId!,
          title: title,
          createdAt: _sessionCreatedDate ?? DateTime.now(),
          lastMessageAt: DateTime.now(),
          messages: messageDataList,
        );
        await AppShared.addChatSession(userId, newSession);
      }

      log('✅ Chat session saved: $_currentSessionId');
    } catch (e) {
      log('❌ Error saving chat session: $e');
    }
  }

  /// Xóa chat hiện tại
  Future<void> clearCurrentChat() async {
    try {
      if (_currentSessionId != null) {
        await AppShared.deleteChatSession(userId, _currentSessionId!);
        log('🗑️ Deleted current chat session: $_currentSessionId');
      }
      await _initializeChat(showWelcome: true);
    } catch (e) {
      log('❌ Error clearing current chat: $e');
    }
  }

  /// Load lịch sử chat (không làm mất session hiện tại)
  Future<void> loadChatHistory() async {
    emit(ChatHistoryLoading());
    try {
      final sessions = await AppShared.getChatSessions(userId);
      emit(ChatHistoryLoaded(sessions));
    } catch (e) {
      log('❌ Error loading chat history: $e');
      emit(ChatHistoryLoaded([]));
    }
  }

  /// Restore lại state chat hiện tại sau khi xem history
  void restoreChatState() {
    emit(ChatbotLoaded(List.from(_messages)));
    log('🔄 Restored chat state with ${_messages.length} messages');
  }

  /// Load một chat session cụ thể
  Future<void> loadChatSession(
    String sessionId, {
    bool keepHistory = false,
  }) async {
    try {
      final session = await AppShared.getChatSessionById(userId, sessionId);

      if (session == null) {
        emit(ChatbotError("Không tìm thấy phiên chat này", _messages));
        return;
      }

      _currentSessionId = sessionId;
      _sessionCreatedDate = session.createdAt;

      // Chuyển đổi ChatMessageData sang ChatMessage
      _messages = session.messages.map((msgData) {
        return ChatMessage(
          user: msgData.isBot ? botUser : currentUser,
          createdAt: msgData.createdAt,
          text: msgData.text,
        );
      }).toList();

      emit(ChatbotLoaded(_messages));
      log('✅ Loaded chat session: $sessionId');
    } catch (e) {
      log('❌ Error loading chat session: $e');
      emit(ChatbotError("Không thể tải phiên chat", _messages));
    }
  }

  /// Tạo chat mới (chỉ khi user nhấn nút)
  Future<void> createNewChat() async {
    // Lưu session hiện tại trước khi tạo mới
    if (_messages.length > 1) {
      await _saveChatSession();
    }

    await _initializeChat(showWelcome: true);
    log('🆕 Created new chat session');
  }

  /// Kiểm tra nếu session hiện tại đã qua ngày
  bool _isSessionExpired() {
    if (_sessionCreatedDate == null) return false;

    final now = DateTime.now();
    return now.year != _sessionCreatedDate!.year ||
        now.month != _sessionCreatedDate!.month ||
        now.day != _sessionCreatedDate!.day;
  }

  /// Kiểm tra và tự động tạo session mới nếu qua ngày
  Future<void> checkAndCreateNewDaySession() async {
    if (_isSessionExpired()) {
      log('📅 New day detected, creating new session');
      await createNewChat();
    }
  }

  /// Lấy danh sách tin nhắn hiện tại
  List<ChatMessage> get messages => _messages;

  /// Lấy session ID hiện tại
  String? get currentSessionId => _currentSessionId;

  /// Lấy session date hiện tại
  DateTime? get sessionCreatedDate => _sessionCreatedDate;
}
