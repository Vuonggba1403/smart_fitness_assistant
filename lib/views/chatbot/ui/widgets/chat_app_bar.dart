import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_fitness_assistant/core/functions/colo_extension.dart';
import 'package:smart_fitness_assistant/core/widgets/custom_showdialog.dart';
import 'package:smart_fitness_assistant/views/chatbot/logic/cubit/chatbot_cubit.dart';
import 'package:smart_fitness_assistant/views/chatbot/ui/widgets/chat_history_view.dart';

/// AppBar cho Chatbot - Tách riêng để dễ maintain
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return AppBar(
      backgroundColor: cardColor,
      elevation: 1,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: _buildTitle(textColor),
      actions: _buildActions(context, textColor),
    );
  }

  Widget _buildTitle(Color textColor) {
    return Row(
      children: [
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Fitness Assistant",
                style: TextStyle(
                  color: textColor,
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
    );
  }

  List<Widget> _buildActions(BuildContext context, Color textColor) {
    return [
      IconButton(
        icon: Icon(Icons.add, color: textColor),
        onPressed: () => context.read<ChatbotCubit>().createNewChat(),
        tooltip: 'New Chat',
      ),
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: textColor),
        onSelected: (value) => _handleMenuAction(context, value),
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
                Text('Clear Current Chat', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    final cubit = context.read<ChatbotCubit>();

    switch (action) {
      case 'history':
        await cubit.loadChatHistory();
        if (context.mounted) {
          await Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (ctx) => BlocProvider.value(
                    value: cubit,
                    child: const ChatHistoryView(),
                  ),
                ),
              )
              .then((_) => cubit.restoreChatState());
        }
        break;

      case 'clear':
        if (context.mounted) {
          AppConfirmDialog.show(
            context: context,
            title: 'Clear Current Chat',
            content:
                'Are you sure you want to clear the current chat? This action cannot be undone.',
            onYes: () => cubit.clearCurrentChat(),
          );
        }
        break;
    }
  }
}
