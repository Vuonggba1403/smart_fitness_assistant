import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:smart_fitness_assistant/core/functions/color_extension.dart';
import 'package:smart_fitness_assistant/views/chatbot/ui/widgets/chatbot_markdown_style.dart';
import 'package:smart_fitness_assistant/views/chatbot/ui/widgets/typing_indicator.dart'
    hide TypingIndicator;

/// Widget xử lý hiển thị message bubble
class ChatMessageBubble {
  /// Cấu hình MessageOptions cho DashChat
  static MessageOptions buildMessageOptions(
    ChatUser botUser,
    ChatUser currentUser,
  ) {
    return MessageOptions(
      showOtherUsersAvatar: true,
      showTime: false,
      messagePadding: const EdgeInsets.all(12),
      currentUserContainerColor: Colors.transparent,
      containerColor: Colors.transparent,
      textColor: Colors.white,
      currentUserTextColor: Colors.black,
      borderRadius: 18,
      messageRowBuilder: (message, previous, next, isAfterDate, isBeforeDate) {
        return _buildMessageRow(message, botUser, currentUser);
      },
    );
  }

  /// Build message row với avatar và bubble
  static Widget _buildMessageRow(
    ChatMessage message,
    ChatUser botUser,
    ChatUser currentUser,
  ) {
    final isBot = message.user.id == botUser.id;
    final displayName = isBot ? botUser.firstName : currentUser.firstName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (isBot) ...[_buildBotAvatar(), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment: isBot
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                _buildSenderName(displayName, isBot),
                _buildMessageBubble(message.text, isBot),
              ],
            ),
          ),
          if (!isBot) ...[const SizedBox(width: 8), _buildUserAvatar()],
        ],
      ),
    );
  }

  /// Avatar bot
  static Widget _buildBotAvatar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(color: TColor.primaryColor2, width: 1),
        ),
      ),
      child: Image.asset(
        'assets/img/robot-assistant.png',
        width: 16,
        height: 16,
      ),
    );
  }

  /// Avatar user
  static Widget _buildUserAvatar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        shape: BoxShape.circle,
      ),
      child: Image.asset('assets/img/user_select.png', width: 16, height: 16),
    );
  }

  /// Tên người gửi
  static Widget _buildSenderName(String? displayName, bool isBot) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
      child: Text(
        displayName ?? (isBot ? "Fitness Assistant" : "You"),
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Message bubble với gradient
  static Widget _buildMessageBubble(String text, bool isBot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isBot ? Colors.green : Colors.grey.shade200,
        gradient: isBot
            ? const LinearGradient(
                colors: [Color(0xFF3494E6), Color(0xFFec6ead)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isBot ? 4 : 18),
          bottomRight: Radius.circular(isBot ? 18 : 4),
        ),
      ),
      child: isBot ? _buildBotMessage(text) : _buildUserMessage(text),
    );
  }

  /// Nội dung message bot
  static Widget _buildBotMessage(String text) {
    if (text == "...") {
      return const TypingIndicator();
    }

    return MarkdownBody(
      data: text,
      selectable: true,
      shrinkWrap: true,
      styleSheet: ChatbotMarkdownStyle.botMessageStyle(),
    );
  }

  /// Nội dung message user
  static Widget _buildUserMessage(String text) {
    return Text(text, style: ChatbotMarkdownStyle.userMessageStyle());
  }
}
