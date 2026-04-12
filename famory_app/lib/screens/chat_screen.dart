import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/custom_avatar.dart';

class Message {
  final int id;
  final String sender;
  final String text;
  final String time;
  final bool isMine;

  Message({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
    required this.isMine,
  });
}

class ChatScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ChatScreen({super.key, required this.onBack});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<Message> messages = [
    Message(
      id: 1,
      sender: 'Mom',
      text: 'Don\'t forget to pick up groceries!',
      time: '2:34 PM',
      isMine: false,
    ),
    Message(
      id: 2,
      sender: 'Me',
      text: 'Got it! What do we need?',
      time: '2:35 PM',
      isMine: true,
    ),
    Message(
      id: 3,
      sender: 'Mom',
      text: 'Milk, eggs, and bread. Also get some fruits!',
      time: '2:36 PM',
      isMine: false,
    ),
    Message(
      id: 4,
      sender: 'Dad',
      text: 'Can you grab some coffee too?',
      time: '2:38 PM',
      isMine: false,
    ),
    Message(
      id: 5,
      sender: 'Me',
      text: 'Sure thing! On my way now 🚗',
      time: '2:40 PM',
      isMine: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.softBlueBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.deepBlue,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Chat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '4 members',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    CustomAvatar(name: 'Mom', size: AvatarSize.small),
                    SizedBox(width: 4),
                    CustomAvatar(name: 'Dad', size: AvatarSize.small),
                    SizedBox(width: 4),
                    CustomAvatar(name: 'Sarah', size: AvatarSize.small),
                  ],
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: message.isMine
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: message.isMine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!message.isMine)
                            Padding(
                              padding: const EdgeInsets.only(left: 12, bottom: 4),
                              child: Text(
                                message.sender,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: message.isMine
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: Radius.circular(message.isMine ? 20 : 4),
                                bottomRight: Radius.circular(message.isMine ? 4 : 20),
                              ),
                              boxShadow: !message.isMine
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: message.isMine
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                            child: Text(
                              message.time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Input
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgMain,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.sentiment_satisfied_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.mic_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
