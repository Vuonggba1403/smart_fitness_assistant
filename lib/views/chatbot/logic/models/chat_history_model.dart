import 'dart:convert';

/// Model cho một phiên chat
class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<ChatMessageData> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    required this.messages,
  });

  /// Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  /// Tạo từ JSON
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      messages: (json['messages'] as List)
          .map((m) => ChatMessageData.fromJson(m))
          .toList(),
    );
  }

  /// Tạo copy với các thay đổi
  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    List<ChatMessageData>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messages: messages ?? this.messages,
    );
  }
}

/// Model cho một tin nhắn trong chat
class ChatMessageData {
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final bool isBot;

  ChatMessageData({
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    required this.isBot,
  });

  /// Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isBot': isBot,
    };
  }

  /// Tạo từ JSON
  factory ChatMessageData.fromJson(Map<String, dynamic> json) {
    return ChatMessageData(
      userId: json['userId'],
      userName: json['userName'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      isBot: json['isBot'],
    );
  }
}
