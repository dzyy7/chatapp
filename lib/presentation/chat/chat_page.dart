import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatapp/core/constants/app_colors.dart';
import 'package:chatapp/injection.dart';
import 'package:chatapp/data/models/chat_group.dart';
import 'package:chatapp/presentation/chat/bloc/chat_bloc.dart';
import 'package:chatapp/presentation/chat/bloc/chat_event.dart';
import 'package:chatapp/presentation/chat/bloc/chat_state.dart';
import 'package:chatapp/presentation/chat/widgets/message_bubble.dart';
import 'package:chatapp/presentation/chat/widgets/chat_input.dart';

class ChatPage extends StatelessWidget {
  final String groupId;
  final ChatGroup group;

  const ChatPage({
    super.key,
    required this.groupId,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatBloc>()
        ..add(ChatConnectEvent(groupId: groupId, group: group)),
      child: _ChatContent(groupId: groupId, group: group),
    );
  }
}

class _ChatContent extends StatefulWidget {
  final String groupId;
  final ChatGroup group;

  const _ChatContent({
    required this.groupId,
    required this.group,
  });

  @override
  State<_ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends State<_ChatContent> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_isLoadingMore) {
      final state = context.read<ChatBloc>().state;
      if (state is ChatConnected &&
          state.hasMoreHistory &&
          !state.isLoadingHistory) {
        setState(() => _isLoadingMore = true);
        context.read<ChatBloc>().add(ChatLoadHistoryEvent());

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _isLoadingMore = false);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, state),
          body: _buildBody(context, state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatState state) {
    String title = widget.group.name;
    String subtitle = 'Connecting...';

    if (state is ChatConnected) {
      subtitle = 'Connected';
    } else if (state is ChatError) {
      subtitle = 'Disconnected';
    }

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.surface),
        onPressed: () {
          context.read<ChatBloc>().add(ChatDisconnectEvent());
          Navigator.of(context).pop();
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.surface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.surface,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.surface),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ChatState state) {
    if (state is ChatConnecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Connecting to chat...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (state is ChatError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Connection Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ChatBloc>().add(
                      ChatConnectEvent(groupId: widget.groupId, group: widget.group),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry', style: TextStyle(color: AppColors.surface)),
            ),
          ],
        ),
      );
    }

    final messages = state is ChatConnected ? state.messages : <dynamic>[];
    final isLoadingHistory = state is ChatConnected ? state.isLoadingHistory : false;

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start the conversation!',
                        style: TextStyle(color: AppColors.textHint),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length + (isLoadingHistory ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isLoadingHistory) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    return MessageBubble(message: messages[index]);
                  },
                ),
        ),
        ChatInput(
          enabled: state is ChatConnected,
          onSend: (text) {
            context.read<ChatBloc>().add(ChatSendMessageEvent(text: text));
          },
        ),
      ],
    );
  }
}
