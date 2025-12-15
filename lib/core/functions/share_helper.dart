import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_fitness_assistant/core/models/content_post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShareHelper {
  /// ✅ Generate shareable link using Supabase
  static Future<String> generateShareLink(String postId) async {
    try {
      // ✅ Option 1: Lưu link vào database để tracking (tuỳ chọn)
      // await supabase.from('shared_links').insert({
      //   'post_id': postId,
      //   'created_at': DateTime.now().toIso8601String(),
      // });

      // ✅ Option 2: Return deep link trực tiếp (đơn giản nhất)
      return 'smartfitnessassistant://post/$postId';

      // ✅ Option 3: Return short URL (nếu có short URL service)
      // return 'https://sfa.link/$postId';
    } catch (e) {
      print('❌ Error generating share link: $e');
      return 'smartfitnessassistant://post/$postId';
    }
  }

  /// ✅ Save shared link tracking (tuỳ chọn - để analytics)
  static Future<void> trackSharedLink(String postId) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      await supabase.from('shared_links').insert({
        'post_id': postId,
        'shared_by': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('⚠️ Warning tracking shared link: $e');
    }
  }
}
