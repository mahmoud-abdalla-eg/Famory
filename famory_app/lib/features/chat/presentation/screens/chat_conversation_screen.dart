import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../family/data/models/family_member.dart';
import '../../../family/data/services/family_service.dart';
import '../../data/models/message_model.dart';
import '../../data/services/ai_assistant_service.dart';
import '../controllers/chat_controller.dart';

enum ChatConversationType { family, direct, ai }

enum _MessageKind { text, image, file, voice }

class ChatConversationScreen extends StatefulWidget {
  final ChatConversationType type;
  final String title;
  final String subtitle;
  final String initials;
  final Color avatarColor;
  final String? familyId;
  final String? recipientId;

  const ChatConversationScreen.family({super.key, this.familyId})
      : type = ChatConversationType.family,
        title = 'Family Chat',
        subtitle = '4 members',
        initials = 'F',
        avatarColor = AppColors.blue,
        recipientId = null;

  const ChatConversationScreen.direct({
    super.key,
    required String name,
    required String initials,
    required Color color,
    this.recipientId,
  })  : type = ChatConversationType.direct,
        title = name,
        subtitle = 'online',
        initials = initials,
        avatarColor = color,
        familyId = null;

  const ChatConversationScreen.ai({super.key})
      : type = ChatConversationType.ai,
        title = '@famory AI',
        subtitle = 'Powered by DeepSeek',
        initials = 'AI',
        avatarColor = AppColors.g900,
        familyId = null,
        recipientId = null;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  static const String _aiHistoryStorageKey = 'famory_ai_chat_history_v1';
  static List<_ChatEntry>? _aiHistoryMemory;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final ImagePicker _imagePicker = ImagePicker();
  final ChatController _chatController = ChatController();
  final AiAssistantService _aiAssistant = AiAssistantService();

  late List<_ChatEntry> _messages;
  StreamSubscription<PlayerState>? _playerSub;
  bool _showEmojiPicker = false;
  bool _isRecording = false;
  bool _isLoadingHistory = false;
  bool _isSendingBackend = false;
  String? _playingVoicePath;
  String? _currentUserId;
  String? _historyError;

  bool get _isAi => widget.type == ChatConversationType.ai;
  String? get _familyId => widget.familyId ?? FamilyService().familyId;
  bool get _canUseBackend {
    if (_isAi) {
      return false;
    }

    if (widget.type == ChatConversationType.family) {
      final id = _familyId?.trim();
      return id != null && id.isNotEmpty;
    }

    final recipientId = widget.recipientId?.trim();
    return recipientId != null && recipientId.isNotEmpty;
  }

  String get _headerSubtitle {
    if (_isLoadingHistory) {
      return 'Loading messages...';
    }

    if (_isSendingBackend) {
      return _isAi ? 'Thinking...' : 'Sending...';
    }

    if (widget.type == ChatConversationType.family) {
      final count = FamilyService().members.length;
      if (count > 0) {
        return '$count ${count == 1 ? 'member' : 'members'}';
      }
    }

    return _isRecording ? 'Recording voice...' : widget.subtitle;
  }

  @override
  void initState() {
    super.initState();
    _messages = _initialMessages();
    if (_isAi) {
      _loadAiHistory();
    } else {
      _loadBackendHistory();
    }
    _playerSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && mounted) {
        setState(() => _playingVoicePath = null);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_saveAiHistory());
    _messageController.dispose();
    _scrollController.dispose();
    _playerSub?.cancel();
    _player.dispose();
    _recorder.dispose();
    super.dispose();
  }

  List<_ChatEntry> _initialMessages() {
    if (_canUseBackend) {
      return const [];
    }

    if (_isAi) {
      final memoryHistory = _aiHistoryMemory;
      if (memoryHistory != null && memoryHistory.isNotEmpty) {
        return List<_ChatEntry>.from(memoryHistory);
      }

      return [
        const _ChatEntry(
          sender: '@famory AI',
          text:
              'Hi Sarah! I am your family assistant. Ask me about tasks, calendar, meals, or anything family.',
          time: '3:30 PM',
          initials: 'AI',
          color: AppColors.g900,
          isAi: true,
        ),
      ];
    }

    if (widget.type == ChatConversationType.direct) {
      return [
        _ChatEntry(
          sender: widget.title.split(' ').first,
          text: 'I will be home in 10 mins',
          time: '2:34 PM',
          initials: widget.initials,
          color: widget.avatarColor,
        ),
        const _ChatEntry(
          text: 'Great, see you soon.',
          time: '2:35 PM',
          isMine: true,
        ),
      ];
    }

    return [
      const _ChatEntry(
        sender: 'Mom',
        text: 'Don\'t forget to pick up groceries!',
        time: '2:34 PM',
        initials: 'M',
        color: Color(0xFFEC4899),
      ),
      const _ChatEntry(
        text: 'Got it! What do we need?',
        time: '2:35 PM',
        isMine: true,
      ),
      const _ChatEntry(
        sender: 'Mom',
        text: 'Milk, eggs, and bread. Also some fruits!',
        time: '2:36 PM',
        initials: 'M',
        color: Color(0xFFEC4899),
      ),
      const _ChatEntry(
        sender: 'Dad',
        text: 'Can you grab some coffee too?',
        time: '2:38 PM',
        initials: 'D',
        color: Color(0xFFF59E0B),
      ),
      const _ChatEntry(
        text: 'Sure thing! On my way now.',
        time: '2:40 PM',
        isMine: true,
      ),
    ];
  }

  Future<void> _loadBackendHistory() async {
    if (!_canUseBackend) {
      return;
    }

    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id');

      if (widget.type == ChatConversationType.family) {
        await _chatController.loadFamilyHistory(_familyId!);
      } else {
        await _chatController.loadPrivateHistory(widget.recipientId!);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _messages = _chatController.messages.map(_entryFromModel).toList();
      });
      _scrollToBottom();
    } catch (error) {
      if (mounted) {
        setState(() => _historyError = _friendlyMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  Future<void> _sendText([String? overrideText]) async {
    final text = (overrideText ?? _messageController.text).trim();
    if (text.isEmpty) {
      return;
    }

    _messageController.clear();
    setState(() => _showEmojiPicker = false);

    if (_isAi) {
      await _sendAiText(text);
      return;
    }

    if (_canUseBackend) {
      await _sendBackendText(text);
      return;
    }

    setState(() {
      _messages.add(
        _ChatEntry(
          text: text,
          time: _formatTime(DateTime.now()),
          isMine: true,
        ),
      );
    });
    await _saveAiHistory();
    _scrollToBottom();
  }

  Future<void> _sendAiText(String text) async {
    final thinkingStartedAt = DateTime.now();
    setState(() {
      _messages.add(
        _ChatEntry(
          text: text,
          time: _formatTime(DateTime.now()),
          isMine: true,
        ),
      );
      _messages.add(
        _ChatEntry(
          sender: '@famory AI',
          text: 'Thinking...',
          time: _formatTime(thinkingStartedAt),
          initials: 'AI',
          color: AppColors.g900,
          isAi: true,
        ),
      );
      _isSendingBackend = true;
    });
    await _saveAiHistory();
    _scrollToBottom();

    try {
      final result = await _aiAssistant.processMessage(text);
      if (!mounted) {
        return;
      }

      setState(() {
        _replaceThinkingMessage(
          _ChatEntry(
            sender: '@famory AI',
            text: result.reply,
            time: _formatTime(DateTime.now()),
            initials: 'AI',
            color: AppColors.g900,
            isAi: true,
          ),
        );
      });

      if (result.taskCreated) {
        _showSnack('Task added successfully');
      }
      if (result.calendarEventCreated) {
        _showSnack('Event added to calendar');
      }
      await _saveAiHistory();
      _scrollToBottom();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _replaceThinkingMessage(
          _ChatEntry(
            sender: '@famory AI',
            text: 'I could not complete that yet: ${_friendlyMessage(error)}',
            time: _formatTime(DateTime.now()),
            initials: 'AI',
            color: AppColors.g900,
            isAi: true,
          ),
        );
      });
      await _saveAiHistory();
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() => _isSendingBackend = false);
      }
    }
  }

  Future<void> _loadAiHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_aiHistoryStorageKey);
      if (raw == null || raw.isEmpty) {
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return;
      }

      final restored = decoded
          .whereType<Map>()
          .map((entry) => _entryFromStoredJson(Map<String, dynamic>.from(entry)))
          .whereType<_ChatEntry>()
          .toList();

      if (restored.isEmpty || !mounted) {
        return;
      }

      _aiHistoryMemory = List<_ChatEntry>.from(restored);
      setState(() => _messages = restored);
      _scrollToBottom();
    } catch (_) {
      return;
    }
  }

  Future<void> _saveAiHistory() async {
    if (!_isAi) {
      return;
    }

    final history = _messages.where((message) => message.text.trim().isNotEmpty).toList();
    _aiHistoryMemory = List<_ChatEntry>.from(history);

    final prefs = await SharedPreferences.getInstance();
    final entries = history
        .map(_entryToStoredJson)
        .toList();
    await prefs.setString(_aiHistoryStorageKey, jsonEncode(entries));
  }

  Map<String, dynamic> _entryToStoredJson(_ChatEntry entry) {
    return {
      'sender': entry.sender,
      'text': entry.text,
      'time': entry.time,
      'isMine': entry.isMine,
      'initials': entry.initials,
      'color': entry.color.value,
      'isAi': entry.isAi,
      'kind': entry.kind.name,
      'filePath': entry.filePath,
      'fileName': entry.fileName,
    };
  }

  _ChatEntry? _entryFromStoredJson(Map<String, dynamic> json) {
    final text = json['text']?.toString();
    if (text == null || text.trim().isEmpty) {
      return null;
    }

    final kindName = json['kind']?.toString();
    final kind = _MessageKind.values.firstWhere(
      (value) => value.name == kindName,
      orElse: () => _MessageKind.text,
    );

    final colorValue = int.tryParse(json['color']?.toString() ?? '');
    return _ChatEntry(
      sender: json['sender']?.toString(),
      text: text,
      time: json['time']?.toString() ?? _formatTime(DateTime.now()),
      isMine: json['isMine'] == true,
      initials: json['initials']?.toString() ?? '',
      color: colorValue == null ? AppColors.g900 : Color(colorValue),
      isAi: json['isAi'] == true,
      kind: kind,
      filePath: json['filePath']?.toString(),
      fileName: json['fileName']?.toString(),
    );
  }

  void _replaceThinkingMessage(_ChatEntry replacement) {
    final index = _messages.lastIndexWhere(
      (message) => message.isAi && message.text == 'Thinking...',
    );
    if (index >= 0) {
      _messages[index] = replacement;
      return;
    }

    _messages.add(replacement);
  }

  Future<void> _sendBackendText(String text) async {
    setState(() => _isSendingBackend = true);

    try {
      await _loadCurrentUserIdIfNeeded();
      final model = widget.type == ChatConversationType.family
          ? await _chatController.sendFamilyMessage(
              familyId: _familyId!,
              message: text,
            )
          : await _chatController.sendPrivateMessage(
              recipientId: widget.recipientId!,
              message: text,
            );

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(_entryFromModel(model));
        _historyError = null;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _messageController.text = text;
      _messageController.selection = TextSelection.collapsed(offset: text.length);
      _showSnack(_friendlyMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSendingBackend = false);
      }
    }
  }

  Future<void> _loadCurrentUserIdIfNeeded() async {
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('user_id');
  }

  _ChatEntry _entryFromModel(MessageModel message) {
    final isMine = message.senderId == _currentUserId;
    final member = _memberForSender(message.senderId);
    final senderName = isMine ? null : member?.name ?? 'Family member';

    return _ChatEntry(
      sender: senderName,
      text: message.message,
      time: _formatTime(message.createdAt ?? DateTime.now()),
      isMine: isMine,
      initials: member?.initials ?? _initialsFromName(senderName ?? widget.title),
      color: _memberColor(message.senderId),
    );
  }

  FamilyMember? _memberForSender(String senderId) {
    if (senderId.isEmpty) {
      return null;
    }

    for (final member in FamilyService().members) {
      if (member.id == senderId) {
        return member;
      }
    }

    return null;
  }

  Color _memberColor(String senderId) {
    const colors = [
      AppColors.blue,
      Color(0xFFEC4899),
      Color(0xFFF59E0B),
      AppColors.purple,
      Color(0xFF10B981),
    ];
    final members = FamilyService().members;
    final index = members.indexWhere((member) => member.id == senderId);
    if (index < 0) {
      return widget.avatarColor;
    }

    return colors[index % colors.length];
  }

  String _initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'M';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _toggleEmojiPicker() {
    FocusScope.of(context).unfocus();
    setState(() => _showEmojiPicker = !_showEmojiPicker);
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(withData: false);
      final file = result?.files.single;
      if (file == null || file.path == null) {
        return;
      }

      setState(() {
        _messages.add(
          _ChatEntry(
            text: file.name,
            time: _formatTime(DateTime.now()),
            isMine: true,
            kind: _MessageKind.file,
            filePath: file.path,
            fileName: file.name,
          ),
        );
        _showEmojiPicker = false;
      });
      await _saveAiHistory();
      _scrollToBottom();
    } catch (error) {
      _showSnack('Could not pick file: $error');
    }
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (image == null) {
        return;
      }

      setState(() {
        _messages.add(
          _ChatEntry(
            text: _fileNameFromPath(image.path),
            time: _formatTime(DateTime.now()),
            isMine: true,
            kind: _MessageKind.image,
            filePath: image.path,
            fileName: _fileNameFromPath(image.path),
          ),
        );
        _showEmojiPicker = false;
      });
      await _saveAiHistory();
      _scrollToBottom();
    } catch (error) {
      _showSnack('Could not add photo: $error');
    }
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        final path = await _recorder.stop();
        setState(() => _isRecording = false);
        if (path == null) {
          return;
        }

        setState(() {
          _messages.add(
            _ChatEntry(
              text: 'Voice message',
              time: _formatTime(DateTime.now()),
              isMine: true,
              kind: _MessageKind.voice,
              filePath: path,
              fileName: _fileNameFromPath(path),
            ),
          );
        });
        await _saveAiHistory();
        _scrollToBottom();
        return;
      }

      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _showSnack('Microphone permission is required for voice messages.');
        return;
      }

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/famory_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      setState(() {
        _isRecording = true;
        _showEmojiPicker = false;
      });
    } catch (error) {
      setState(() => _isRecording = false);
      _showSnack('Voice recording failed: $error');
    }
  }

  Future<void> _toggleVoicePlayback(String path) async {
    try {
      if (_playingVoicePath == path && _player.playing) {
        await _player.pause();
        setState(() => _playingVoicePath = null);
        return;
      }

      await _player.stop();
      await _player.setFilePath(path);
      setState(() => _playingVoicePath = path);
      await _player.play();
    } catch (error) {
      setState(() => _playingVoicePath = null);
      _showSnack('Could not play voice message: $error');
    }
  }

  void _showMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search messages'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text('Notifications'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(_isAi ? 'AI details' : 'Chat details'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToLogin() {
    Get.offAllNamed(AppRoutes.sessionExpired);
  }

  bool _isAuthError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('expired token') ||
        lower.contains('invalid or expired') ||
        lower.contains('session expired') ||
        lower.contains('log in');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _friendlyMessage(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }

    return text;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _fileNameFromPath(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Column(
        children: [
          _ConversationHeader(
            title: widget.title,
            subtitle: _headerSubtitle,
            initials: widget.initials,
            avatarColor: widget.avatarColor,
            isAi: _isAi,
            onMenuTap: _showMenu,
          ),
          if (_historyError != null)
            _ChatErrorBanner(
              message: _historyError!,
              actionLabel: _isAuthError(_historyError!) ? 'Log in' : 'Retry',
              onAction: _isAuthError(_historyError!) ? _goToLogin : _loadBackendHistory,
            ),
          Expanded(
            child: _isLoadingHistory && _messages.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blue),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _MessageRow(
                      message: _messages[index],
                      isAiChat: _isAi,
                      isPlaying: _messages[index].filePath != null &&
                          _messages[index].filePath == _playingVoicePath &&
                          _player.playing,
                      onPlayVoice: _toggleVoicePlayback,
                    ),
                  ),
          ),
          if (_isAi)
            _AiQuickActions(
              onSelected: (text) {
                _sendText(text);
              },
            ),
          _ChatInputBar(
            controller: _messageController,
            isRecording: _isRecording,
            onSend: _sendText,
            onEmoji: _toggleEmojiPicker,
            onAttach: _pickFile,
            onPhoto: _pickPhoto,
            onVoice: _toggleRecording,
          ),
          if (_showEmojiPicker)
            SizedBox(
              height: 260,
              child: EmojiPicker(
                textEditingController: _messageController,
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatErrorBanner extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _ChatErrorBanner({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF1F2),
      padding: const EdgeInsets.fromLTRB(14, 9, 10, 9),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.red,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String initials;
  final Color avatarColor;
  final bool isAi;
  final VoidCallback onMenuTap;

  const _ConversationHeader({
    required this.title,
    required this.subtitle,
    required this.initials,
    required this.avatarColor,
    required this.isAi,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              _HeaderButton(icon: Icons.arrow_back, onTap: () => Get.back()),
              const SizedBox(width: 10),
              _HeaderAvatar(
                initials: initials,
                color: avatarColor,
                isAi: isAi,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.g900,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.g400,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _HeaderButton(icon: Icons.more_vert, onTap: onMenuTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFEFF8FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.g500, size: 21),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  final String initials;
  final Color color;
  final bool isAi;

  const _HeaderAvatar({
    required this.initials,
    required this.color,
    required this.isAi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isAi ? Colors.white : color,
        shape: BoxShape.circle,
        border: isAi ? Border.all(color: AppColors.g200) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: isAi
          ? Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset('assets/images/Splash_logo.webp'),
            )
          : Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  final _ChatEntry message;
  final bool isAiChat;
  final bool isPlaying;
  final ValueChanged<String> onPlayVoice;

  const _MessageRow({
    required this.message,
    required this.isAiChat,
    required this.isPlaying,
    required this.onPlayVoice,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isMine) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _MessageBubble(
                    message: message,
                    isPlaying: isPlaying,
                    onPlayVoice: onPlayVoice,
                  ),
                  const SizedBox(height: 5),
                  _MessageTime(time: message.time),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAiChat)
            _AiMiniAvatar()
          else
            _SenderAvatar(initials: message.initials, color: message.color),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.sender != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 6),
                    child: Text(
                      message.sender!,
                      style: const TextStyle(
                        color: AppColors.g500,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                _MessageBubble(
                  message: message,
                  isPlaying: isPlaying,
                  onPlayVoice: onPlayVoice,
                ),
                const SizedBox(height: 5),
                _MessageTime(time: message.time),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatEntry message;
  final bool isPlaying;
  final ValueChanged<String> onPlayVoice;

  const _MessageBubble({
    required this.message,
    required this.isPlaying,
    required this.onPlayVoice,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final bubbleColor = isMine
        ? const Color(0xFF43B7E8)
        : message.isAi
            ? AppColors.g900
            : Colors.white;

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(15),
          topRight: const Radius.circular(15),
          bottomLeft: Radius.circular(isMine ? 15 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _MessageContent(
        message: message,
        isPlaying: isPlaying,
        onPlayVoice: onPlayVoice,
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final _ChatEntry message;
  final bool isPlaying;
  final ValueChanged<String> onPlayVoice;

  const _MessageContent({
    required this.message,
    required this.isPlaying,
    required this.onPlayVoice,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        message.isMine || message.isAi ? Colors.white : AppColors.g800;

    switch (message.kind) {
      case _MessageKind.image:
        final path = message.filePath;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (path != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(path),
                  width: 210,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              message.fileName ?? 'Photo',
              style: TextStyle(color: textColor, fontSize: 12),
            ),
          ],
        );
      case _MessageKind.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, color: textColor, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message.fileName ?? message.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      case _MessageKind.voice:
        final path = message.filePath;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: path == null ? null : () => onPlayVoice(path),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: message.isMine ? 0.18 : 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: message.isMine ? Colors.white : AppColors.blue,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.graphic_eq, color: textColor, size: 24),
            const SizedBox(width: 8),
            Text(
              isPlaying ? 'Playing' : 'Voice message',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      case _MessageKind.text:
        return Text(
          message.text,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }
}

class _SenderAvatar extends StatelessWidget {
  final String initials;
  final Color color;

  const _SenderAvatar({required this.initials, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 17,
      backgroundColor: color,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AiMiniAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: AppColors.g900,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Image.asset('assets/images/Splash_logo.webp'),
      ),
    );
  }
}

class _MessageTime extends StatelessWidget {
  final String time;

  const _MessageTime({required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        time,
        style: const TextStyle(
          color: AppColors.g400,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AiQuickActions extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const _AiQuickActions({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(58, 0, 14, 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _QuickActionChip(label: 'Tasks due today?', onTap: onSelected),
          _QuickActionChip(label: 'Plan dinner', onTap: onSelected),
          _QuickActionChip(label: 'Fairness report', onTap: onSelected),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final ValueChanged<String> onTap;

  const _QuickActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(label),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.g200),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.g900,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  final ValueChanged<String> onSend;
  final VoidCallback onEmoji;
  final VoidCallback onAttach;
  final VoidCallback onPhoto;
  final VoidCallback onVoice;

  const _ChatInputBar({
    required this.controller,
    required this.isRecording,
    required this.onSend,
    required this.onEmoji,
    required this.onAttach,
    required this.onPhoto,
    required this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.fromLTRB(11, 4, 6, 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _InputIcon(icon: Icons.sentiment_satisfied_alt, onTap: onEmoji),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: onSend,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: AppColors.g400,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              _InputIcon(icon: Icons.attach_file, onTap: onAttach),
              _InputIcon(icon: Icons.photo_camera, onTap: onPhoto),
              _InputIcon(
                icon: isRecording ? Icons.stop_circle : Icons.mic,
                onTap: onVoice,
                color: isRecording ? AppColors.red : AppColors.g500,
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => onSend(controller.text),
                borderRadius: BorderRadius.circular(21),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFF43B7E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _InputIcon({
    required this.icon,
    required this.onTap,
    this.color = AppColors.g500,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 28,
        height: 36,
        child: Icon(icon, color: color, size: 19),
      ),
    );
  }
}

class _ChatEntry {
  final String? sender;
  final String text;
  final String time;
  final bool isMine;
  final String initials;
  final Color color;
  final bool isAi;
  final _MessageKind kind;
  final String? filePath;
  final String? fileName;

  const _ChatEntry({
    this.sender,
    required this.text,
    required this.time,
    this.isMine = false,
    this.initials = '',
    this.color = AppColors.blue,
    this.isAi = false,
    this.kind = _MessageKind.text,
    this.filePath,
    this.fileName,
  });
}
