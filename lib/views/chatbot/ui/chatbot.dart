import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/chatbot/ui/widgets/chat_history_view.dart';
import '../logic/cubit/chatbot_cubit.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Khi app được mở lại, check xem có qua ngày mới không
      context.read<ChatbotCubit>().checkAndCreateNewDaySession();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy username và userId từ AuthenticationCubit
    final authCubit = context.read<AuthenticationCubit>();
    final username = authCubit.userDataModel?.username ?? "You";
    final userId = authCubit.userDataModel?.userId ?? "";

    return BlocProvider(
      create: (context) => ChatbotCubit(userId: userId, username: username),
      child: const _ChatBotView(),
    );
  }
}

class _ChatBotView extends StatelessWidget {
  const _ChatBotView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildChatBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Avatar của bot
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Image.asset(
              'assets/img/robot-assistant.png',
              width: 32,
              height: 32,
            ),
          ),
          const SizedBox(width: 12),
          // Thông tin bot
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Fitness Assistant",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Your personal fitness companion",
                  style: TextStyle(
                    fontSize: 11,
                    color: TColor.primaryColor2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Nút tạo chat mới
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () async {
            // Lưu session hiện tại trước khi tạo mới
            await context.read<ChatbotCubit>().createNewChat();
          },
          tooltip: 'New Chat',
        ),
        // Nút menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) async {
            final cubit = context.read<ChatbotCubit>();

            if (value == 'history') {
              // Load chat history và mở view
              await cubit.loadChatHistory();
              if (context.mounted) {
                // Navigate và đợi kết quả quay lại
                await Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (ctx) => BlocProvider.value(
                          value: cubit,
                          child: const ChatHistoryView(),
                        ),
                      ),
                    )
                    .then((_) {
                      // Khi quay lại, restore lại state chat
                      cubit.restoreChatState();
                    });
              }
            } else if (value == 'clear') {
              // Hiển thị dialog xác nhận
              _showClearDialog(context, cubit);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, size: 20),
                  SizedBox(width: 12),
                  Text('View All Chats'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text(
                    'Clear Current Chat',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Hiển thị dialog xác nhận xóa chat hiện tại
  void _showClearDialog(BuildContext context, ChatbotCubit cubit) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Current Chat'),
        content: const Text(
          'Are you sure you want to clear the current chat? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cubit.clearCurrentChat();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Xây dựng nội dung chat với BlocBuilder
  Widget _buildChatBody(BuildContext context) {
    return BlocBuilder<ChatbotCubit, ChatbotState>(
      builder: (context, state) {
        final cubit = context.read<ChatbotCubit>();

        // Lấy danh sách tin nhắn từ state
        List<ChatMessage> messages = [];
        if (state is ChatbotLoaded) {
          messages = state.messages;
        } else if (state is ChatbotResponding) {
          messages = state.messages;
        } else if (state is ChatbotError) {
          messages = state.messages;
        }

        return DashChat(
          currentUser: cubit.currentUser,
          messages: messages,
          onSend: (ChatMessage message) {
            cubit.sendMessage(message);
          },
          messageOptions: _buildMessageOptions(
            cubit.botUser,
            cubit.currentUser,
          ),
          inputOptions: _buildInputOptions(),
        );
      },
    );
  }

  /// Cấu hình hiển thị tin nhắn
  MessageOptions _buildMessageOptions(ChatUser botUser, ChatUser currentUser) {
    return MessageOptions(
      showOtherUsersAvatar: true,
      showTime: false,
      messagePadding: const EdgeInsets.all(12),
      currentUserContainerColor: Colors.transparent,
      containerColor: Colors.transparent,
      textColor: Colors.white,
      currentUserTextColor: Colors.black,
      borderRadius: 18,
      // Custom builder cho từng tin nhắn
      messageRowBuilder: (message, previous, next, isAfterDate, isBeforeDate) {
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
              // Avatar cho bot (bên trái)
              if (isBot) ...[
                Container(
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
                ),
                const SizedBox(width: 8),
              ],
              // Nội dung tin nhắn
              Flexible(
                child: Column(
                  crossAxisAlignment: isBot
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    // Hiển thị tên người gửi
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 4,
                        left: 4,
                        right: 4,
                      ),
                      child: Text(
                        displayName ?? (isBot ? "Fitness Assistant" : "You"),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: isBot ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar cho user (bên phải)
              if (!isBot) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/img/user_select.png',
                    width: 16,
                    height: 16,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Cấu hình input field
  InputOptions _buildInputOptions() {
    return InputOptions(
      inputDecoration: InputDecoration(
        hintText: "Chat Những Gì Bạn Muốn...",
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
      // Custom nút gửi
      sendButtonBuilder: (onSend) {
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
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
            onPressed: onSend,
          ),
        );
      },
    );
  }
}
