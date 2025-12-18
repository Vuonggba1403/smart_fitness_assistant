part of 'chatbot_cubit.dart';

@immutable
sealed class ChatbotState {}

/// Trạng thái khởi tạo
final class ChatbotInitial extends ChatbotState {}

/// Trạng thái đang tải
final class ChatbotLoading extends ChatbotState {
  final List<ChatMessage> messages;

  ChatbotLoading(this.messages);
}

/// Trạng thái đã tải xong
final class ChatbotLoaded extends ChatbotState {
  final List<ChatMessage> messages;

  ChatbotLoaded(this.messages);
}

/// Trạng thái đang nhận phản hồi từ bot
final class ChatbotResponding extends ChatbotState {
  final List<ChatMessage> messages;

  ChatbotResponding(this.messages);
}

/// Trạng thái lỗi
final class ChatbotError extends ChatbotState {
  final String message;
  final List<ChatMessage> messages;

  ChatbotError(this.message, this.messages);
}

/// Trạng thái đang load lịch sử chat
final class ChatHistoryLoading extends ChatbotState {}

/// Trạng thái đã load lịch sử chat
final class ChatHistoryLoaded extends ChatbotState {
  final List<ChatSession> sessions;

  ChatHistoryLoaded(this.sessions);
}
