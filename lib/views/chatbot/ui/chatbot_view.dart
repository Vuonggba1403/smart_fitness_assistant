import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/views/auth/cubit/authentication_cubit.dart';
import 'package:smart_fitness_assistant/views/chatbot/ui/widgets/chat_app_bar.dart';
import 'package:smart_fitness_assistant/views/chatbot/ui/widgets/chat_input_field.dart';
import 'package:smart_fitness_assistant/views/chatbot/ui/widgets/chat_message_bubble.dart';
import '../logic/cubit/chatbot_cubit.dart';

/// Main Chatbot View - Clean và tối giản
class ChatBot extends StatelessWidget {
  const ChatBot({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthenticationCubit>();
    final username = authCubit.userDataModel?.username ?? "You";
    final userId = authCubit.userDataModel?.userId ?? "";

    // ✅ FIX: Tạo BlocProvider mới mỗi lần để đảm bảo state mới hoàn toàn
    return BlocProvider(
      create: (context) => ChatbotCubit(userId: userId, username: username),
      child: const _ChatBotView(),
    );
  }
}

class _ChatBotView extends StatefulWidget {
  const _ChatBotView();

  @override
  State<_ChatBotView> createState() => _ChatBotViewState();
}

class _ChatBotViewState extends State<_ChatBotView>
    with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<ChatbotCubit>().checkAndCreateNewDaySession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const ChatAppBar(), body: _buildChatBody(context));
  }

  Widget _buildChatBody(BuildContext context) {
    return BlocBuilder<ChatbotCubit, ChatbotState>(
      builder: (context, state) {
        final cubit = context.read<ChatbotCubit>();

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
          onSend: (ChatMessage message) => cubit.sendMessage(message),
          messageOptions: ChatMessageBubble.buildMessageOptions(
            cubit.botUser,
            cubit.currentUser,
          ),
          inputOptions: ChatInputField.buildInputOptions(),
        );
      },
    );
  }
}
