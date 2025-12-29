import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:smart_fitness_assistant/core/functions/app_shared.dart';
import 'package:smart_fitness_assistant/core/models/chat_history_model.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';
import 'package:uuid/uuid.dart';

part 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final Gemini _gemini = Gemini.instance;
  final String userId;
  List<ChatMessage> _messages = [];
  String? _currentSessionId;
  DateTime? _sessionCreatedDate;

  // ✅ FIX: Đổi type thành dynamic hoặc StreamSubscription<dynamic>
  StreamSubscription? _currentStreamSubscription;

  final ChatUser botUser = ChatUser(id: "bot", firstName: "Fitness Assistant");

  late final ChatUser currentUser;

  ChatbotCubit({required this.userId, String? username})
    : super(ChatbotInitial()) {
    currentUser = ChatUser(id: "user", firstName: username ?? "You");
    log('🆕 ChatbotCubit created for user: $userId');
    _checkAndInitializeChat();
  }

  // ✅ UPDATE: Override close để cancel stream và clear state
  @override
  Future<void> close() {
    log('🗑️ ChatbotCubit disposed for user: $userId');
    _currentStreamSubscription?.cancel(); // ✅ Cancel stream
    _messages.clear();
    _currentSessionId = null;
    _sessionCreatedDate = null;
    return super.close();
  }

  /// Kiểm tra và khởi tạo chat (check ngày mới)
  Future<void> _checkAndInitializeChat() async {
    log('🔍 Checking and initializing chat for user: $userId');

    // Load session gần nhất
    final sessions = await AppShared.getChatSessions(userId);

    if (sessions.isEmpty) {
      log('📝 No existing sessions, creating new chat with welcome');
      await _initializeChat(showWelcome: true);
      return;
    }

    final latestSession = sessions.first;
    final today = DateTime.now();
    final sessionDate = latestSession.createdAt;

    final isSameDay = _isSameDay(today, sessionDate);

    if (isSameDay) {
      log('✅ Loading today\'s session: ${latestSession.id}');
      await loadChatSession(latestSession.id, keepHistory: true);
    } else {
      log('📅 New day detected, creating new session with welcome');
      await _initializeChat(showWelcome: true);
    }
  }

  /// ✅ NEW: Helper method để check cùng ngày
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Khởi tạo chat với tin nhắn chào mừng (delay 1.5s)
  Future<void> _initializeChat({bool showWelcome = true}) async {
    log('🔄 Initializing new chat (showWelcome: $showWelcome)');

    // ✅ FIX: Cancel stream cũ và clear state
    await _currentStreamSubscription?.cancel();
    _currentStreamSubscription = null;

    _messages.clear();
    _currentSessionId = null;
    _sessionCreatedDate = null;

    // Tạo session ID mới
    _currentSessionId = const Uuid().v4();
    _sessionCreatedDate = DateTime.now();

    log('✨ New session ID: $_currentSessionId');

    if (showWelcome) {
      // Emit empty state trước
      emit(ChatbotLoaded([]));

      // Delay 1.5 giây trước khi hiển thị welcome message
      await Future.delayed(const Duration(milliseconds: 1500));

      // Tạo welcome message
      final welcomeMessage = ChatMessage(
        user: botUser,
        createdAt: DateTime.now(),
        text: "Hello, I'm Fitness assistant,\nHow can I help you?",
      );

      _messages = [welcomeMessage];
      emit(ChatbotLoaded(List.from(_messages))); // ✅ Tạo list mới
      log('👋 Welcome message displayed');
    } else {
      _messages = [];
      emit(ChatbotLoaded([]));
      log('⚪ Empty chat initialized');
    }
  }

  /// Gửi tin nhắn từ người dùng
  Future<void> sendMessage(ChatMessage message) async {
    try {
      // ✅ FIX: Cancel stream cũ trước khi gửi câu mới
      await _currentStreamSubscription?.cancel();
      _currentStreamSubscription = null;

      log('💬 Sending new message: ${message.text}');

      // Thêm tin nhắn người dùng vào danh sách
      _messages = [message, ..._messages];
      emit(ChatbotResponding(_messages));

      // ✅ Delay ngắn để tạo cảm giác tự nhiên
      await Future.delayed(const Duration(milliseconds: 300));

      // ✅ Tạo tin nhắn bot với typing indicator
      final botMessage = ChatMessage(
        user: botUser,
        createdAt: DateTime.now(),
        text: "...", // ✅ Typing indicator
      );

      // Thêm tin nhắn bot với "..." vào danh sách
      _messages = [botMessage, ..._messages];
      emit(ChatbotResponding(_messages));

      // ✅ Delay thêm 800ms để user thấy "..."
      await Future.delayed(const Duration(milliseconds: 800));

      // Gọi API Gemini để lấy phản hồi
      await _getGeminiResponse(message.text);
    } catch (e) {
      log('❌ Error sending message: $e');
      emit(ChatbotError(LocaleKey.sendError.tr, _messages));
    }
  }

  /// Lấy phản hồi từ Gemini API
  Future<void> _getGeminiResponse(String userMessage) async {
    try {
      await _currentStreamSubscription?.cancel();

      StringBuffer responseBuffer = StringBuffer();

      // ✅ FIX: Prompt linh hoạt - cho phép trả lời tự nhiên
      final enhancedPrompt =
          '''
You are a friendly fitness assistant named "Fitness Assistant".

CONVERSATION RULES:
1. For greetings (hi, hello, how are you): Reply naturally and friendly
2. For general questions: Answer conversationally 
3. For fitness/health/nutrition questions: Use the structured format below

STRUCTURED FORMAT (only for fitness-related questions):
**[Category Name]:**

• [Item 1] - [brief info]

• [Item 2] - [brief info]

• [Item 3] - [brief info]

• [Item 4] - [brief info]

• [Item 5] - [brief info]

EXAMPLES:

User: "hi"
Response: "Hello! 👋 I'm your Fitness Assistant. How can I help you with your fitness journey today?"

User: "5 món ăn giảm cân"
Response:
**Món Ăn Giảm Cân:**

• Salad ức gà - 150 cal/phần, giàu protein

• Cá hồi nướng - 180 cal/100g, omega-3 cao

• Súp lơ xanh - 55 cal/100g, ít calo

• Trứng luộc - 155 cal/2 trứng, no lâu

• Sữa chua Hy Lạp - 100 cal/100g, probiotic tốt

User: "how are you"
Response: "I'm doing great, thank you! 😊 Ready to help you achieve your fitness goals. What would you like to know?"

NOW RESPOND TO: $userMessage

Remember: 
- Be friendly and conversational for casual chat
- Use structured format ONLY for fitness/nutrition questions
- Keep responses concise and helpful
''';

      bool isFirstChunk = true;

      _currentStreamSubscription = _gemini
          .streamGenerateContent(enhancedPrompt)
          .listen(
            (event) {
              final response = event.output ?? "";

              if (isFirstChunk) {
                responseBuffer.clear();
                isFirstChunk = false;
                log('📨 First chunk received, clearing typing indicator');
              }

              responseBuffer.write(response);

              if (_messages.isNotEmpty && _messages[0].user.id == botUser.id) {
                _messages[0] = ChatMessage(
                  user: botUser,
                  createdAt: _messages[0].createdAt,
                  text: responseBuffer.toString(),
                );

                emit(ChatbotResponding(List.from(_messages)));
              }
            },
            onError: (error) {
              log('❌ Gemini stream error: $error');
              _currentStreamSubscription?.cancel();
              _currentStreamSubscription = null;

              emit(ChatbotError(LocaleKey.connectionError.tr, _messages));
            },
            onDone: () async {
              log('✅ Gemini stream completed');
              _currentStreamSubscription = null;

              emit(ChatbotLoaded(List.from(_messages)));

              await _saveChatSession();
            },
            cancelOnError: true,
          );
    } catch (e) {
      log('❌ Error getting Gemini response: $e');
      _currentStreamSubscription?.cancel();
      _currentStreamSubscription = null;

      emit(ChatbotError(LocaleKey.responseError.tr, _messages));
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

      // ✅ FIX: Chuyển đổi ChatMessage sang ChatMessageData - GIỮ NGUYÊN THỨ TỰ
      // _messages đã ở dạng reversed (mới nhất ở đầu)
      // Khi save, reverse lại để lưu theo thứ tự thời gian tăng dần
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
          title: title,
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
      log('🗑️ Clearing current chat: $_currentSessionId');

      // ✅ FIX: Cancel stream trước khi clear
      await _currentStreamSubscription?.cancel();
      _currentStreamSubscription = null;

      if (_currentSessionId != null) {
        await AppShared.deleteChatSession(userId, _currentSessionId!);
        log('✅ Deleted current chat session: $_currentSessionId');
      }

      // Clear messages trước khi tạo mới
      _messages.clear();
      _currentSessionId = null;
      _sessionCreatedDate = null;

      // Tạo chat mới VÀ hiển thị welcome
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
        emit(ChatbotError(LocaleKey.sessionNotFound.tr, _messages));
        return;
      }

      _currentSessionId = sessionId;
      _sessionCreatedDate = session.createdAt;

      // ✅ FIX: Chuyển đổi ChatMessageData sang ChatMessage
      // session.messages đã lưu theo thứ tự tăng dần (cũ → mới)
      // Cần reverse lại để DashChat hiển thị đúng (mới nhất ở đầu)
      _messages = session.messages.reversed.map((msgData) {
        return ChatMessage(
          user: msgData.isBot ? botUser : currentUser,
          createdAt: msgData.createdAt,
          text: msgData.text,
        );
      }).toList();

      emit(ChatbotLoaded(_messages));
      log('✅ Loaded chat session: $sessionId (${_messages.length} messages)');
    } catch (e) {
      log('❌ Error loading chat session: $e');
      emit(ChatbotError(LocaleKey.cannotLoadSession.tr, _messages));
    }
  }

  /// Tạo chat mới (chỉ khi user nhấn nút)
  Future<void> createNewChat() async {
    log('🆕 Creating new chat...');

    // ✅ FIX: Cancel stream trước khi tạo chat mới
    await _currentStreamSubscription?.cancel();
    _currentStreamSubscription = null;

    // Lưu session hiện tại trước khi tạo mới (nếu có messages)
    if (_messages.length > 1 && _currentSessionId != null) {
      await _saveChatSession();
    }

    // Clear hoàn toàn state cũ
    _messages.clear();
    _currentSessionId = null;
    _sessionCreatedDate = null;

    // Tạo chat mới VÀ hiển thị welcome message
    await _initializeChat(showWelcome: true);
    log('✅ New chat created with welcome message');
  }

  /// Kiểm tra nếu session hiện tại đã qua ngày
  bool _isSessionExpired() {
    if (_sessionCreatedDate == null) return false;

    final now = DateTime.now();
    return !_isSameDay(now, _sessionCreatedDate!);
  }

  /// Kiểm tra và tự động tạo session mới nếu qua ngày
  Future<void> checkAndCreateNewDaySession() async {
    if (_isSessionExpired()) {
      log('📅 New day detected, creating new session');

      // ✅ FIX: Clear messages trước khi tạo session mới
      _messages.clear();
      _currentSessionId = null;
      _sessionCreatedDate = null;

      await _initializeChat(showWelcome: true);
    }
  }

  /// Lấy danh sách tin nhắn hiện tại
  List<ChatMessage> get messages => _messages;

  /// Lấy session ID hiện tại
  String? get currentSessionId => _currentSessionId;

  /// Lấy session date hiện tại
  DateTime? get sessionCreatedDate => _sessionCreatedDate;
}
