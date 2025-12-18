import 'package:dash_chat_2/dash_chat_2.dart';

/// Model cho tin nhắn chat
class ChatMessageModel {
  final ChatMessage message;
  final bool isBot;
  final DateTime timestamp;

  ChatMessageModel({
    required this.message,
    required this.isBot,
    required this.timestamp,
  });

  /// Tạo tin nhắn từ người dùng
  factory ChatMessageModel.fromUser({
    required String text,
    required ChatUser user,
  }) {
    return ChatMessageModel(
      message: ChatMessage(user: user, createdAt: DateTime.now(), text: text),
      isBot: false,
      timestamp: DateTime.now(),
    );
  }

  /// Tạo tin nhắn từ bot
  factory ChatMessageModel.fromBot({
    required String text,
    required ChatUser botUser,
  }) {
    return ChatMessageModel(
      message: ChatMessage(
        user: botUser,
        createdAt: DateTime.now(),
        text: text,
      ),
      isBot: true,
      timestamp: DateTime.now(),
    );
  }
}
