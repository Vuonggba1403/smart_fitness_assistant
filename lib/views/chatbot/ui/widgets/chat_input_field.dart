import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_fitness_assistant/locale/locale_key.dart';

/// Widget xử lý input field cho chat
class ChatInputField {
  /// Cấu hình InputOptions cho DashChat
  static InputOptions buildInputOptions() {
    return InputOptions(
      inputDecoration: _buildInputDecoration(),
      sendButtonBuilder: (onSend) => _buildSendButton(onSend),
      inputTextStyle: TextStyle(
        color: Colors.black,
        fontFamily: 'Poppins',
        fontSize: 13,
      ),
    );
  }

  /// Input decoration với hint text
  static InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: LocaleKey.chatInputHint.tr,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }

  /// Nút gửi với gradient
  static Widget _buildSendButton(Function() onSend) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3494E6), Color(0xFFec6ead)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
        onPressed: onSend,
      ),
    );
  }
}
