import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:smart_fitness_assistant/core/functions/app_shared.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/views/chatbot/logic/cubit/chatbot_cubit.dart';
import 'package:smart_fitness_assistant/core/models/chat_history_model.dart';

class ChatHistoryView extends StatelessWidget {
  const ChatHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Chat History",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<ChatbotCubit, ChatbotState>(
        builder: (context, state) {
          if (state is ChatHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatHistoryLoaded) {
            if (state.sessions.isEmpty) {
              return _buildEmptyState();
            }
            return _buildSessionList(context, state.sessions);
          }

          return const SizedBox();
        },
      ),
    );
  }

  /// Widget khi chưa có lịch sử chat
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No chat history yet",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start a conversation to see it here",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  /// Danh sách các session
  Widget _buildSessionList(BuildContext context, List<ChatSession> sessions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(context, session);
      },
    );
  }

  /// Card cho mỗi session
  Widget _buildSessionCard(BuildContext context, ChatSession session) {
    final cubit = context.read<ChatbotCubit>();
    final isCurrentSession = cubit.currentSessionId == session.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentSession
            ? BorderSide(color: TColor.primaryColor2, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (isCurrentSession) {
            // Nếu đã là session hiện tại, chỉ cần đóng history
            Navigator.of(context).pop();
          } else {
            // Load session khác và quay lại màn hình chat
            await cubit.loadChatSession(session.id);
            if (context.mounted) {
              Navigator.of(context).pop(); // Quay lại chat screen
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrentSession
                      ? TColor.primaryColor2.withOpacity(0.1)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat,
                  color: isCurrentSession
                      ? TColor.primaryColor2
                      : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isCurrentSession
                                  ? TColor.primaryColor2
                                  : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentSession)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: TColor.primaryColor2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Active",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${session.messages.length} messages',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                        Text(
                          _formatDate(session.lastMessageAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Nút xóa (không hiển thị cho active session)
              if (!isCurrentSession)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: () => _showDeleteDialog(context, session),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hiển thị dialog xác nhận xóa
  void _showDeleteDialog(BuildContext context, ChatSession session) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text('Are you sure you want to delete "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final cubit = context.read<ChatbotCubit>();

              // Xóa chat
              await AppShared.deleteChatSession(cubit.userId, session.id);

              // Reload danh sách
              await cubit.loadChatHistory();

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
  }

  /// Format ngày giờ
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}
