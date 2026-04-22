import 'package:flutter/material.dart';
import '../../../../theme.dart';
import '../../../calendar/data/services/event_service.dart';

/// Enhanced Chat Screen with AI Assistant, Mentions, Emoji, Voice, Attachments
class ChatScreenEnhanced extends StatefulWidget {
  final VoidCallback onBack;

  const ChatScreenEnhanced({super.key, required this.onBack});

  @override
  State<ChatScreenEnhanced> createState() => _ChatScreenEnhancedState();
}

class _ChatScreenEnhancedState extends State<ChatScreenEnhanced> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _showEmojiPicker = false;
  bool _showMentionDropdown = false;
  bool _showHeaderMenu = false;
  bool _showMembersModal = false;
  bool _isRecording = false;
  String _mentionSearch = '';

  final List<FamilyMember> _familyMembers = [
    FamilyMember(id: '1', name: 'Mom', isAI: false),
    FamilyMember(id: '2', name: 'Dad', isAI: false),
    FamilyMember(id: '3', name: 'Sarah', isAI: false),
    FamilyMember(id: '4', name: 'Jake', isAI: false),
    FamilyMember(id: 'ai', name: 'Famory AI', isAI: true),
  ];

  @override
  void initState() {
    super.initState();
    _initializeMessages();
    _messageController.addListener(_onTextChanged);
  }

  void _initializeMessages() {
    _messages.addAll([
      ChatMessage(
        id: 1,
        text: "Don't forget to pick up groceries!",
        isMine: false,
        sender: "Mom",
        time: "2:34 PM",
      ),
      ChatMessage(
        id: 2,
        text: "Got it! What do we need?",
        isMine: true,
        time: "2:35 PM",
      ),
      ChatMessage(
        id: 3,
        text: "Milk, eggs, and bread. Also get some fruits!",
        isMine: false,
        sender: "Mom",
        time: "2:36 PM",
      ),
      ChatMessage(
        id: 4,
        text: "Can you grab some coffee too?",
        isMine: false,
        sender: "Dad",
        time: "2:38 PM",
      ),
      ChatMessage(
        id: 5,
        text: "Sure thing! On my way now 🚗",
        isMine: true,
        time: "2:40 PM",
      ),
    ]);
  }

  void _onTextChanged() {
    final text = _messageController.text;
    final lastWord = text.split(' ').last;

    if (lastWord.startsWith('@')) {
      setState(() {
        _showMentionDropdown = true;
        _mentionSearch = lastWord.substring(1);
      });
    } else {
      setState(() {
        _showMentionDropdown = false;
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final mentions = _detectMentions(_messageController.text);
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      text: _messageController.text,
      isMine: true,
      time: _formatTime(DateTime.now()),
      mentions: mentions.isNotEmpty ? mentions : null,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
      _showEmojiPicker = false;
    });

    _scrollToBottom();
    _processAIMessage(_messageController.text, mentions);
  }

  List<String> _detectMentions(String text) {
    final regex = RegExp(r'@(\w+(?:\s+\w+)?)');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(1)!).toList();
  }

  void _processAIMessage(String text, List<String> mentions) {
    final isAIMentioned = mentions.any(
      (m) => m.toLowerCase().contains('ai') || m.toLowerCase().contains('famory'),
    );

    if (!isAIMentioned) return;

    String aiResponse = "";
    String? toastMessage;

    final lowerText = text.toLowerCase();
    if (lowerText.contains('appointment') || lowerText.contains('meeting')) {
      // Parse date and create actual calendar event
      final eventDate = _parseDateFromText(lowerText);
      final eventTitle = _extractEventTitle(text);

      final event = CalendarEventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: eventTitle,
        date: eventDate,
        startTime: '2:00 PM',
        endTime: '3:00 PM',
        color: AppColors.primaryBlue,
      );

      EventService().addEvent(event);

      aiResponse = "Sure! I've added your appointment to the calendar for ${_formatDate(eventDate)}.";
      toastMessage = "Event added to your calendar";
    } else if (lowerText.contains('remind')) {
      aiResponse = "Reminder set! I'll notify you when it's time.";
      toastMessage = "Reminder created successfully";
    } else if (lowerText.contains('task') || lowerText.contains('todo')) {
      aiResponse = "Task created! I've added it to your task list.";
      toastMessage = "Task added successfully";
    } else {
      aiResponse = "I'm here to help! I can create events, set reminders, and manage tasks for your family.";
    }

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch,
          text: aiResponse,
          isMine: false,
          sender: "Famory AI",
          time: _formatTime(DateTime.now()),
          isAI: true,
        ));
      });
      _scrollToBottom();

      if (toastMessage != null) {
        _showToast(toastMessage);
      }
    });
  }

  DateTime _parseDateFromText(String text) {
    final now = DateTime.now();

    if (text.contains('tomorrow')) {
      return now.add(const Duration(days: 1));
    } else if (text.contains('next monday') || text.contains('monday')) {
      int daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
      if (daysUntilMonday == 0) daysUntilMonday = 7; // Next week if today is Monday
      return now.add(Duration(days: daysUntilMonday));
    } else if (text.contains('next tuesday') || text.contains('tuesday')) {
      int daysUntilTuesday = (DateTime.tuesday - now.weekday + 7) % 7;
      if (daysUntilTuesday == 0) daysUntilTuesday = 7;
      return now.add(Duration(days: daysUntilTuesday));
    } else if (text.contains('next wednesday') || text.contains('wednesday')) {
      int daysUntilWednesday = (DateTime.wednesday - now.weekday + 7) % 7;
      if (daysUntilWednesday == 0) daysUntilWednesday = 7;
      return now.add(Duration(days: daysUntilWednesday));
    } else if (text.contains('next thursday') || text.contains('thursday')) {
      int daysUntilThursday = (DateTime.thursday - now.weekday + 7) % 7;
      if (daysUntilThursday == 0) daysUntilThursday = 7;
      return now.add(Duration(days: daysUntilThursday));
    } else if (text.contains('next friday') || text.contains('friday')) {
      int daysUntilFriday = (DateTime.friday - now.weekday + 7) % 7;
      if (daysUntilFriday == 0) daysUntilFriday = 7;
      return now.add(Duration(days: daysUntilFriday));
    } else if (text.contains('next saturday') || text.contains('saturday')) {
      int daysUntilSaturday = (DateTime.saturday - now.weekday + 7) % 7;
      if (daysUntilSaturday == 0) daysUntilSaturday = 7;
      return now.add(Duration(days: daysUntilSaturday));
    } else if (text.contains('next sunday') || text.contains('sunday')) {
      int daysUntilSunday = (DateTime.sunday - now.weekday + 7) % 7;
      if (daysUntilSunday == 0) daysUntilSunday = 7;
      return now.add(Duration(days: daysUntilSunday));
    }

    // Default to tomorrow if no specific date found
    return now.add(const Duration(days: 1));
  }

  String _extractEventTitle(String text) {
    // Remove mentions
    String cleaned = text.replaceAll(RegExp(r'@\w+(\s+\w+)?'), '').trim();

    // Remove common trigger words
    cleaned = cleaned
        .replaceAll(RegExp(r'\b(add|create|schedule|set up)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\b(appointment|meeting)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\b(for|on|at)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\b(next|this)\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\b(tomorrow)\b', caseSensitive: false), '')
        .trim();

    // Clean up extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned.isNotEmpty ? cleaned : 'New Event';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _selectMention(String name) {
    final words = _messageController.text.split(' ');
    words[words.length - 1] = '@$name ';
    _messageController.text = words.join(' ');
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
    setState(() {
      _showMentionDropdown = false;
    });
  }

  void _insertEmoji(String emoji) {
    final text = _messageController.text;
    final selection = _messageController.selection;
    final newText = text.replaceRange(selection.start, selection.end, emoji);
    _messageController.text = newText;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: selection.start + emoji.length),
    );
  }

  Future<void> _pickFile() async {
    // Mock file picker - Replace with actual file_picker package when installed
    // final result = await FilePicker.platform.pickFiles();
    // For now, show a demo file attachment
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        text: 'Sent a file: document.pdf',
        isMine: true,
        time: _formatTime(DateTime.now()),
        attachmentName: 'document.pdf',
      ));
    });
    _scrollToBottom();

    // Show info that packages need to be installed
    _showToast('Install file_picker package for real file selection');
  }

  Future<void> _pickImage() async {
    // Mock image picker - Replace with actual image_picker package when installed
    // final picker = ImagePicker();
    // final image = await picker.pickImage(source: ImageSource.gallery);
    // For now, show a demo photo attachment
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        text: 'Sent a photo: family_photo.jpg',
        isMine: true,
        time: _formatTime(DateTime.now()),
        attachmentName: 'family_photo.jpg',
      ));
    });
    _scrollToBottom();

    // Show info that packages need to be installed
    _showToast('Install image_picker package for real photo selection');
  }

  void _toggleVoiceRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isRecording = false;
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch,
            text: 'Voice message',
            isMine: true,
            time: _formatTime(DateTime.now()),
            isVoice: true,
          ));
        });
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => _buildMessage(_messages[index]),
                ),
              ),
              _buildInputArea(),
            ],
          ),
          if (_showHeaderMenu) _buildHeaderMenu(),
          if (_showMembersModal) _buildMembersModal(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl + AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.softBlueBg,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.deepBlue,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Family Chat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showMembersModal = true;
                    });
                  },
                  child: const Text(
                    '4 members',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showHeaderMenu = !_showHeaderMenu;
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.softBlueBg,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.deepBlue,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: message.isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isMine && message.sender != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      message.sender!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: message.isAI
                        ? const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          )
                        : null,
                    color: message.isAI
                        ? null
                        : message.isMine
                            ? AppColors.primaryBlue
                            : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isMine ? 20 : 4),
                      bottomRight: Radius.circular(message.isMine ? 4 : 20),
                    ),
                    boxShadow: !message.isMine
                        ? AppShadows.soft
                        : null,
                  ),
                  child: message.isVoice
                      ? _buildVoiceMessage()
                      : message.attachmentName != null
                          ? _buildAttachment(message.attachmentName!)
                          : _buildMessageText(message),
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
          ),
        ],
      ),
    );
  }

  Widget _buildMessageText(ChatMessage message) {
    if (message.mentions == null || message.mentions!.isEmpty) {
      return Text(
        message.text,
        style: TextStyle(
          fontSize: 14,
          color: message.isMine || message.isAI
              ? Colors.white
              : AppColors.textPrimary,
        ),
      );
    }

    final parts = message.text.split(RegExp(r'(@\w+(?:\s+\w+)?)'));
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          color: message.isMine || message.isAI
              ? Colors.white
              : AppColors.textPrimary,
        ),
        children: parts.map((part) {
          if (part.startsWith('@')) {
            final isAIMention = part.toLowerCase().contains('ai') ||
                part.toLowerCase().contains('famory');
            return TextSpan(
              text: part,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                backgroundColor: message.isMine
                    ? Colors.white.withValues(alpha: 0.2)
                    : isAIMention
                        ? AppColors.primaryBlue.withValues(alpha: 0.1)
                        : AppColors.successGreen.withValues(alpha: 0.1),
                color: message.isMine
                    ? Colors.white
                    : isAIMention
                        ? const Color(0xFF8B5CF6)
                        : AppColors.primaryBlue,
              ),
            );
          }
          return TextSpan(text: part);
        }).toList(),
      ),
    );
  }

  Widget _buildVoiceMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mic, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '0:03',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildAttachment(String fileName) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.attach_file, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            fileName,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showMentionDropdown) _buildMentionDropdown(),
          if (_showEmojiPicker) _buildEmojiPicker(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgMain,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.sentiment_satisfied_rounded, size: 20),
                  color: AppColors.textSecondary,
                  onPressed: () {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message or @mention...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file, size: 20),
                  color: AppColors.textSecondary,
                  onPressed: _pickFile,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, size: 20),
                  color: AppColors.textSecondary,
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: Icon(
                    Icons.mic,
                    size: 20,
                    color: _isRecording ? AppColors.error : AppColors.textSecondary,
                  ),
                  onPressed: _toggleVoiceRecording,
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, size: 20),
                    color: Colors.white,
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentionDropdown() {
    final filtered = _familyMembers
        .where((m) =>
            m.name.toLowerCase().contains(_mentionSearch.toLowerCase()))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.medium,
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final member = filtered[index];
          return ListTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: member.isAI
                    ? const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      )
                    : const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.accentOrange],
                      ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  member.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            title: Text(member.name),
            subtitle: member.isAI ? const Text('AI Assistant') : null,
            onTap: () => _selectMention(member.name),
          );
        },
      ),
    );
  }

  Widget _buildEmojiPicker() {
    final emojis = ['😊', '😂', '🥰', '😍', '❤️', '👍', '🔥', '⭐', '🎉', '💯'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.medium,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: emojis.map((emoji) {
          return GestureDetector(
            onTap: () {
              _insertEmoji(emoji);
              setState(() {
                _showEmojiPicker = false;
              });
            },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeaderMenu() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showHeaderMenu = false;
        });
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.only(
              top: AppSpacing.xxl + 60,
              right: AppSpacing.lg,
            ),
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.elevated,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuItem(
                  Icons.people_rounded,
                  'View Members',
                  () {
                    setState(() {
                      _showHeaderMenu = false;
                      _showMembersModal = true;
                    });
                  },
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  Icons.settings_rounded,
                  'Settings',
                  () {
                    setState(() {
                      _showHeaderMenu = false;
                    });
                  },
                ),
                const Divider(height: 1),
                _buildMenuItem(
                  Icons.notifications_rounded,
                  'Notifications',
                  () {
                    setState(() {
                      _showHeaderMenu = false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersModal() {
    final members = [
      {'name': 'Mom', 'avatar': 'M', 'status': 'Active'},
      {'name': 'Dad', 'avatar': 'D', 'status': 'Active'},
      {'name': 'Sarah', 'avatar': 'S', 'status': 'Away'},
      {'name': 'Jake', 'avatar': 'J', 'status': 'Active'},
    ];

    return GestureDetector(
      onTap: () {
        setState(() {
          _showMembersModal = false;
        });
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent dismissal when tapping modal content
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: AppShadows.elevated,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Family Members',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showMembersModal = false;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.bgMain,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Members List
                  ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isActive = member['status'] == 'Active';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.bgMain,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryBlue,
                                      AppColors.accentOrange,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    member['avatar'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      member['status'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.successGreen
                                      : AppColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Close Button
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showMembersModal = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final int id;
  final String text;
  final bool isMine;
  final String? sender;
  final String time;
  final bool isAI;
  final List<String>? mentions;
  final String? attachmentName;
  final bool isVoice;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    this.sender,
    required this.time,
    this.isAI = false,
    this.mentions,
    this.attachmentName,
    this.isVoice = false,
  });
}

class FamilyMember {
  final String id;
  final String name;
  final bool isAI;

  FamilyMember({
    required this.id,
    required this.name,
    required this.isAI,
  });
}
