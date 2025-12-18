import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Best practice Markdown style cho chatbot
class ChatbotMarkdownStyle {
  static MarkdownStyleSheet botMessageStyle() {
    return MarkdownStyleSheet(
      // Paragraph - nội dung thường
      p: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.4, // ✅ BEST PRACTICE
        wordSpacing: 1.0,
        letterSpacing: 0.3,
      ),

      // Title / Header
      h1: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: 0.4,
      ),
      h2: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.3,
      ),
      h3: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.3,
      ),

      // Bold
      strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),

      // Italic
      em: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),

      // ✅ LIST – FIX CHÍNH
      listBullet: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        height: 1.3, // ✅ khoảng cách giữa các dòng list
      ),
      listIndent: 20,
      listBulletPadding: const EdgeInsets.only(right: 6),

      // Code inline
      code: TextStyle(
        backgroundColor: Colors.white.withOpacity(0.2),
        color: Colors.white,
        fontFamily: 'monospace',
        fontSize: 13,
      ),

      // Blockquote
      blockquote: const TextStyle(
        color: Colors.white70,
        fontStyle: FontStyle.italic,
        height: 1.4,
      ),
      blockquoteDecoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: const Border(left: BorderSide(color: Colors.white54, width: 3)),
      ),

      // ✅ SPACING – GỌN NHƯ CHAT APP
      blockSpacing: 6, // giữa các khối
      pPadding: const EdgeInsets.symmetric(vertical: 2),

      h1Padding: const EdgeInsets.only(bottom: 4),
      h2Padding: const EdgeInsets.only(bottom: 4),
      h3Padding: const EdgeInsets.only(bottom: 4),
    );
  }

  static TextStyle userMessageStyle() {
    return const TextStyle(
      color: Colors.black87,
      fontSize: 14,
      height: 1.4,
      letterSpacing: 0.3,
    );
  }
}
