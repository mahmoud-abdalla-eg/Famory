import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../calendar/data/services/event_service.dart';
import '../../../family/data/models/family_member.dart';
import '../../../family/data/services/family_service.dart';
import '../../../tasks/data/services/task_service.dart';

class AiAssistantService {
  AiAssistantService({TaskService? taskService})
      : _taskService = taskService ?? TaskService();

  final TaskService _taskService;
  final EventService _eventService = EventService();
  _CalendarProposal? _pendingCalendarProposal;

  Future<AiAssistantResult> processMessage(String message) async {
    final greeting = _greetingReply(message);
    if (greeting != null) {
      return AiAssistantResult(reply: greeting);
    }

    final calendarConfirmation = _handleCalendarConfirmation(message);
    if (calendarConfirmation != null) {
      return calendarConfirmation;
    }

    final apiKey = EnvConfig.deepSeekApiKey;
    final taskIntent = await _taskIntentFrom(message, apiKey);
    if (taskIntent != null) {
      return _createTask(taskIntent);
    }

    final calendarProposal = _calendarProposalFrom(message);
    if (calendarProposal != null) {
      _pendingCalendarProposal = calendarProposal;
      return AiAssistantResult(reply: _calendarProposalReply(calendarProposal));
    }

    if (apiKey != null && apiKey.isNotEmpty) {
      final reply = await _askDeepSeek(message, apiKey);
      return AiAssistantResult(reply: reply);
    }

    return AiAssistantResult(reply: _offlineReply(message));
  }

  AiAssistantResult? _handleCalendarConfirmation(String message) {
    final lower = message.trim().toLowerCase();
    final proposal = _pendingCalendarProposal;
    if (proposal == null) {
      return null;
    }

    final accepted = {
      'yes',
      'y',
      'yeah',
      'yep',
      'sure',
      'ok',
      'okay',
      'set it',
      'do it',
      'add it',
      'schedule it',
    }.contains(lower);
    final declined = {'no', 'n', 'nope', 'cancel', 'not now'}.contains(lower);

    if (declined) {
      _pendingCalendarProposal = null;
      return const AiAssistantResult(reply: 'Okay, I will leave the calendar unchanged.');
    }

    if (!accepted) {
      return null;
    }

    _eventService.addEvent(
      CalendarEventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: proposal.title,
        date: proposal.start,
        startTime: _formatClock(proposal.start),
        endTime: _formatClock(proposal.end),
        color: AppColors.blue,
      ),
    );
    _pendingCalendarProposal = null;

    return AiAssistantResult(
      reply:
          'Done. I added "${proposal.title}" on ${_friendlyDate(proposal.start)} from ${_formatClock(proposal.start)} to ${_formatClock(proposal.end)}.',
      calendarEventCreated: true,
    );
  }

  _CalendarProposal? _calendarProposalFrom(String message) {
    final lower = message.trim().toLowerCase();
    if (!_looksLikeCalendarRequest(lower)) {
      return null;
    }

    final title = _calendarTitleFrom(message);
    final duration = _durationForCalendarRequest(lower);
    final searchStart = DateTime.now();
    final slot = _findFreeSlot(
      startSearch: searchStart,
      duration: duration,
      preferEvening: lower.contains('dinner'),
    );

    if (slot == null) {
      return _CalendarProposal(
        title: title,
        start: searchStart.add(const Duration(days: 1)),
        end: searchStart.add(const Duration(days: 1, hours: 1)),
        hadGap: false,
      );
    }

    return _CalendarProposal(
      title: title,
      start: slot.start,
      end: slot.end,
      hadGap: true,
    );
  }

  bool _looksLikeCalendarRequest(String lowerMessage) {
    final calendarWords = lowerMessage.contains('calendar') ||
        lowerMessage.contains('schedule') ||
        lowerMessage.contains('event') ||
        lowerMessage.contains('appointment') ||
        lowerMessage.contains('meeting') ||
        lowerMessage.contains('free time') ||
        lowerMessage.contains('free slot') ||
        lowerMessage.contains('gap');
    final planningWords = lowerMessage.contains('plan ') ||
        lowerMessage.startsWith('plan') ||
        lowerMessage.contains('set a date') ||
        lowerMessage.contains('find time');

    return calendarWords || planningWords;
  }

  String _calendarTitleFrom(String message) {
    var title = message
        .replaceAll(RegExp(r'@?famory\s+ai', caseSensitive: false), '')
        .replaceAll(
          RegExp(
            r'\b(can you|please|find|free|time|slot|gap|calendar|schedule|event|appointment|meeting|set|date|for|to|on|at)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (title.isEmpty) {
      title = 'Family event';
    }

    if (title.toLowerCase() == 'plan dinner' || title.toLowerCase() == 'dinner') {
      return 'Dinner';
    }

    title = title.replaceFirst(RegExp(r'^plan\s+', caseSensitive: false), '');
    return _sentenceCase(title.isEmpty ? 'Family event' : title);
  }

  Duration _durationForCalendarRequest(String lowerMessage) {
    if (lowerMessage.contains('dinner')) {
      return const Duration(hours: 1, minutes: 30);
    }
    if (lowerMessage.contains('meeting') || lowerMessage.contains('appointment')) {
      return const Duration(hours: 1);
    }
    return const Duration(hours: 1);
  }

  _CalendarSlot? _findFreeSlot({
    required DateTime startSearch,
    required Duration duration,
    required bool preferEvening,
  }) {
    for (var dayOffset = 0; dayOffset < 14; dayOffset++) {
      final day = DateTime(startSearch.year, startSearch.month, startSearch.day + dayOffset);
      final windows = preferEvening
          ? [
              _CalendarSlot(
                start: DateTime(day.year, day.month, day.day, 17),
                end: DateTime(day.year, day.month, day.day, 21),
              ),
              _CalendarSlot(
                start: DateTime(day.year, day.month, day.day, 9),
                end: DateTime(day.year, day.month, day.day, 17),
              ),
            ]
          : [
              _CalendarSlot(
                start: DateTime(day.year, day.month, day.day, 9),
                end: DateTime(day.year, day.month, day.day, 21),
              ),
            ];

      for (final window in windows) {
        final searchFrom = dayOffset == 0 && startSearch.isAfter(window.start)
            ? _roundUpToNextHalfHour(startSearch)
            : window.start;
        final slot = _findFreeSlotInWindow(
          window.copyWith(start: searchFrom),
          duration,
          _eventsForDay(day),
        );
        if (slot != null) {
          return slot;
        }
      }
    }

    return null;
  }

  _CalendarSlot? _findFreeSlotInWindow(
    _CalendarSlot window,
    Duration duration,
    List<_CalendarSlot> busySlots,
  ) {
    var cursor = window.start;
    final sortedBusy = busySlots..sort((a, b) => a.start.compareTo(b.start));

    for (final busy in sortedBusy) {
      if (busy.end.isBefore(window.start) || busy.start.isAfter(window.end)) {
        continue;
      }

      if (!cursor.add(duration).isAfter(busy.start)) {
        return _CalendarSlot(start: cursor, end: cursor.add(duration));
      }

      if (busy.end.isAfter(cursor)) {
        cursor = busy.end;
      }
    }

    if (!cursor.add(duration).isAfter(window.end)) {
      return _CalendarSlot(start: cursor, end: cursor.add(duration));
    }

    return null;
  }

  List<_CalendarSlot> _eventsForDay(DateTime day) {
    return _eventService.getEventsForDate(day).map((event) {
      final start = _dateTimeFromEventTime(day, event.startTime ?? event.time) ??
          DateTime(day.year, day.month, day.day, 9);
      final end = _dateTimeFromEventTime(day, event.endTime) ?? start.add(const Duration(hours: 1));
      return _CalendarSlot(start: start, end: end);
    }).toList();
  }

  DateTime? _dateTimeFromEventTime(DateTime day, String? timeText) {
    if (timeText == null || timeText.trim().isEmpty) {
      return null;
    }

    final parsed = _timeOfDayFrom('at ${timeText.trim().toLowerCase()}');
    if (parsed == null) {
      return null;
    }

    return DateTime(day.year, day.month, day.day, parsed.hour, parsed.minute);
  }

  DateTime _roundUpToNextHalfHour(DateTime value) {
    final minutes = value.minute;
    final addMinutes = minutes == 0 || minutes == 30
        ? 0
        : minutes < 30
            ? 30 - minutes
            : 60 - minutes;
    final rounded = value.add(Duration(minutes: addMinutes));
    return DateTime(rounded.year, rounded.month, rounded.day, rounded.hour, rounded.minute);
  }

  String _calendarProposalReply(_CalendarProposal proposal) {
    if (!proposal.hadGap) {
      return 'I could not find a clear calendar gap in the next two weeks. Should I still set "${proposal.title}" for ${_friendlyDate(proposal.start)} at ${_formatClock(proposal.start)}?';
    }

    return 'I found a free calendar gap: ${_friendlyDate(proposal.start)} from ${_formatClock(proposal.start)} to ${_formatClock(proposal.end)}. Should I set "${proposal.title}" for this time?';
  }

  Future<AiAssistantResult> _createTask(_TaskIntent intent) async {
    final familyId = FamilyService().familyId?.trim();
    if (familyId == null || familyId.isEmpty) {
      return const AiAssistantResult(
        reply: 'Create or join a family first, then I can add tasks for you.',
      );
    }

    if (intent.assignedToId.isEmpty) {
      return const AiAssistantResult(
        reply: 'I found the task, but no family member is loaded to assign it to.',
      );
    }

    final task = await _taskService.createTask(
      familyId: familyId,
      title: intent.title,
      assignedTo: intent.assignedToId,
      dueDate: intent.dueDate,
      description: 'Created by Famory AI from chat.',
    );

    return AiAssistantResult(
      reply:
          'Done. I added "${task.title}" to Tasks for ${intent.assignedToName}, due ${_friendlyDueDate(intent.dueDate)}.',
      taskCreated: true,
    );
  }

  Future<_TaskIntent?> _taskIntentFrom(String message, String? apiKey) async {
    final cleanMessage = message.trim();
    if (cleanMessage.isEmpty || !_looksLikeTaskRequest(cleanMessage)) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('user_id')?.trim() ?? '';
    final members = FamilyService().members;

    if (apiKey != null && apiKey.isNotEmpty) {
      final aiIntent = await _taskIntentFromDeepSeek(
        message: cleanMessage,
        apiKey: apiKey,
        members: members,
        currentUserId: currentUserId,
      );
      if (aiIntent != null) {
        return aiIntent;
      }
    }

    final assignee = _assigneeFrom(cleanMessage, members, currentUserId);
    final dueDate = _dueDateFrom(cleanMessage);
    final title = _titleFrom(cleanMessage, assignee);

    if (title.length < 3) {
      return null;
    }

    return _TaskIntent(
      title: title,
      assignedToId: assignee?.id ?? currentUserId,
      assignedToName: assignee?.name ?? 'you',
      dueDate: dueDate,
    );
  }

  bool _looksLikeTaskRequest(String message) {
    final lower = message.toLowerCase();
    final taskWords =
        lower.contains('task') || lower.contains('todo') || lower.contains('to-do');
    final actionWords = lower.contains('add ') ||
        lower.contains('create ') ||
        lower.contains('make ') ||
        lower.contains('new ') ||
        lower.startsWith('remind me to ');

    return (taskWords && actionWords) || lower.startsWith('remind me to ');
  }

  Future<_TaskIntent?> _taskIntentFromDeepSeek({
    required String message,
    required String apiKey,
    required List<FamilyMember> members,
    required String currentUserId,
  }) async {
    try {
      final now = DateTime.now();
      final memberLines = members
          .map((member) => '- ${member.name} | role: ${member.role} | id: ${member.id}')
          .join('\n');
      final payload = await _askDeepSeekJson(
        apiKey: apiKey,
        messages: [
          {
            'role': 'system',
            'content': '''
You extract family task creation requests into JSON only.
Return exactly one JSON object with these keys:
is_task: boolean
title: string
assignee_hint: string
due_iso: string

Rules:
- title must be the actual action to do, not the user's whole sentence.
- Remove phrases like "add a task", "someone else", "anyone", "for me", assignee names, and due date words from title.
- Convert messy wording into a natural short task title.
- If user says "someone else", "anyone else", or similar, use assignee_hint "someone_else".
- If user says "me", "myself", or similar, use assignee_hint "me".
- If user names a family member or role, use that exact name or role as assignee_hint.
- If no due date is said, use today two hours from now.
- Use local current date/time: ${now.toIso8601String()}.
- due_iso must be ISO-8601 local time.
- Do not include markdown.
''',
          },
          {
            'role': 'user',
            'content': 'Family members:\n$memberLines\n\nRequest: $message',
          },
        ],
      );

      if (payload == null || payload['is_task'] != true) {
        return null;
      }

      final title = payload['title']?.toString().trim();
      if (title == null || title.length < 3) {
        return null;
      }

      final assignee = _assigneeFromHint(
        payload['assignee_hint']?.toString(),
        members,
        currentUserId,
      );
      final dueDate = DateTime.tryParse(payload['due_iso']?.toString() ?? '')?.toLocal() ??
          _dueDateFrom(message);

      return _TaskIntent(
        title: _sentenceCase(title),
        assignedToId: assignee?.id ?? currentUserId,
        assignedToName: assignee?.name ?? 'you',
        dueDate: dueDate,
      );
    } catch (_) {
      return null;
    }
  }

  FamilyMember? _assigneeFrom(
    String message,
    List<FamilyMember> members,
    String currentUserId,
  ) {
    final lower = message.toLowerCase();
    for (final member in members) {
      final name = member.name.toLowerCase();
      final role = member.role.toLowerCase();
      if ((name.isNotEmpty && lower.contains(name)) ||
          (role.isNotEmpty && lower.contains(role))) {
        return member;
      }
    }

    if (_wantsSomeoneElse(lower)) {
      return _someoneElse(members, currentUserId);
    }

    for (final member in members) {
      if (member.id == currentUserId) {
        return member;
      }
    }

    return members.isEmpty ? null : members.first;
  }

  FamilyMember? _assigneeFromHint(
    String? hint,
    List<FamilyMember> members,
    String currentUserId,
  ) {
    final lower = hint?.trim().toLowerCase();
    if (lower == null || lower.isEmpty) {
      return _currentUserOrFirst(members, currentUserId);
    }

    if (lower == 'someone_else' || lower == 'someone else' || lower == 'anyone else') {
      return _someoneElse(members, currentUserId);
    }

    if (lower == 'me' || lower == 'myself' || lower == 'current_user') {
      return _currentUserOrFirst(members, currentUserId);
    }

    for (final member in members) {
      if (member.name.toLowerCase() == lower || member.role.toLowerCase() == lower) {
        return member;
      }
    }

    for (final member in members) {
      if (member.name.toLowerCase().contains(lower) ||
          member.role.toLowerCase().contains(lower)) {
        return member;
      }
    }

    return _currentUserOrFirst(members, currentUserId);
  }

  bool _wantsSomeoneElse(String lowerMessage) {
    return lowerMessage.contains('someone else') ||
        lowerMessage.contains('anyone else') ||
        lowerMessage.contains('somebody else') ||
        lowerMessage.contains('another person');
  }

  FamilyMember? _someoneElse(List<FamilyMember> members, String currentUserId) {
    for (final member in members) {
      if (member.id.isNotEmpty && member.id != currentUserId) {
        return member;
      }
    }

    return members.isEmpty ? null : members.first;
  }

  FamilyMember? _currentUserOrFirst(List<FamilyMember> members, String currentUserId) {
    for (final member in members) {
      if (member.id == currentUserId) {
        return member;
      }
    }

    return members.isEmpty ? null : members.first;
  }

  DateTime _dueDateFrom(String message) {
    final now = DateTime.now();
    final lower = message.toLowerCase();
    final timeOfDay = _timeOfDayFrom(lower);

    final inDaysMatch = RegExp(r'\bin\s+(\d{1,2})\s+days?\b').firstMatch(lower);
    if (inDaysMatch != null) {
      final days = int.tryParse(inDaysMatch.group(1) ?? '') ?? 0;
      final date = now.add(Duration(days: days));
      return DateTime(
        date.year,
        date.month,
        date.day,
        timeOfDay?.hour ?? 18,
        timeOfDay?.minute ?? 0,
      );
    }

    if (lower.contains('tomorrow')) {
      final date = now.add(const Duration(days: 1));
      return DateTime(
        date.year,
        date.month,
        date.day,
        timeOfDay?.hour ?? 18,
        timeOfDay?.minute ?? 0,
      );
    }

    if (lower.contains('today')) {
      return DateTime(
        now.year,
        now.month,
        now.day,
        timeOfDay?.hour ?? now.add(const Duration(hours: 2)).hour,
        timeOfDay?.minute ?? 0,
      );
    }

    for (final entry in _weekdays.entries) {
      if (lower.contains(entry.key)) {
        return _nextWeekday(entry.value, timeOfDay);
      }
    }

    if (timeOfDay != null) {
      return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    }

    return now.add(const Duration(hours: 2));
  }

  DateTime _nextWeekday(int weekday, _ParsedTime? timeOfDay) {
    final now = DateTime.now();
    var daysUntil = weekday - now.weekday;
    if (daysUntil <= 0) {
      daysUntil += 7;
    }
    final date = now.add(Duration(days: daysUntil));
    return DateTime(
      date.year,
      date.month,
      date.day,
      timeOfDay?.hour ?? 18,
      timeOfDay?.minute ?? 0,
    );
  }

  _ParsedTime? _timeOfDayFrom(String lowerMessage) {
    final match = RegExp(r'\b(?:before|by|at)\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b')
        .firstMatch(lowerMessage);
    if (match == null) {
      return null;
    }

    var hour = int.tryParse(match.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    final period = match.group(3);
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59 || period == null) {
      return null;
    }

    if (period == 'am') {
      hour = hour == 12 ? 0 : hour;
    } else {
      hour = hour == 12 ? 12 : hour + 12;
    }

    return _ParsedTime(hour: hour, minute: minute);
  }

  String _titleFrom(String message, FamilyMember? assignee) {
    var title = message
        .replaceAll(RegExp(r'@?famory\s+ai', caseSensitive: false), '')
        .replaceAll(RegExp(r'\bplease\b', caseSensitive: false), '')
        .trim();

    title = title
        .replaceFirst(
          RegExp(
            r'^(can you\s+)?(add|create|make|new)\s+(a\s+)?(task|todo|to-do)\s+(for|to)?\s*',
            caseSensitive: false,
          ),
          '',
        )
        .replaceFirst(
          RegExp(r'^remind me to\s+', caseSensitive: false),
          '',
        );

    final assigneeName = assignee?.name.trim();
    if (assigneeName != null && assigneeName.isNotEmpty) {
      final escapedName = RegExp.escape(assigneeName);
      title = title
          .replaceFirst(
            RegExp(r'^(for|to)\s+' + escapedName + r'\s+(to\s+do\s+)?',
                caseSensitive: false),
            '',
          )
          .replaceAll(
            RegExp(r'\b(for|to)\s+' + escapedName + r'\b', caseSensitive: false),
            '',
          );
    }

    title = title
        .replaceAll(
          RegExp(
            r'\b(today|tomorrow|next\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday)|on\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday)|by\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday)|in\s+\d{1,2}\s+days?|(?:before|by|at)\s+\d{1,2}(?::\d{2})?\s*(?:am|pm))\b',
            caseSensitive: false,
          ),
          '',
        )
        .replaceFirst(
          RegExp(
            r'^(someone else|anyone else|somebody else|another person)\s+(to\s+)?',
            caseSensitive: false,
          ),
          '',
        )
        .replaceFirst(RegExp(r'\blike\s+\w+\b', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^(to\s+do|do)\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    title = title.replaceAll(RegExp(r'^(for|to)\s+', caseSensitive: false), '');
    if (title.isEmpty) {
      return 'New task';
    }

    return _sentenceCase(title);
  }

  String _sentenceCase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  Future<String> _askDeepSeek(String message, String apiKey) async {
    final data = await _askDeepSeekRaw(
      apiKey: apiKey,
      messages: [
        {
          'role': 'system',
          'content':
              'You are Famory AI, a concise family assistant. Help with tasks, routines, meals, reminders, and planning. Keep replies short and practical.',
        },
        {'role': 'user', 'content': message},
      ],
      maxTokens: 220,
    );

    final choices = data['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      if (first is Map) {
        final content =
            first['message'] is Map ? (first['message'] as Map)['content']?.toString() : null;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
    }

    return 'I am ready, but the AI response was empty.';
  }

  Future<Map<String, dynamic>?> _askDeepSeekJson({
    required String apiKey,
    required List<Map<String, String>> messages,
  }) async {
    final data = await _askDeepSeekRaw(
      apiKey: apiKey,
      messages: messages,
      maxTokens: 260,
      responseFormat: const {'type': 'json_object'},
    );
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      return null;
    }

    final first = choices.first as Map;
    final content =
        first['message'] is Map ? (first['message'] as Map)['content']?.toString() : null;
    if (content == null || content.trim().isEmpty) {
      return null;
    }

    return _decodeJsonObject(content);
  }

  Future<Map<String, dynamic>> _askDeepSeekRaw({
    required String apiKey,
    required List<Map<String, String>> messages,
    required int maxTokens,
    Map<String, dynamic>? responseFormat,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 20);

    try {
      final request = await client.postUrl(
        _deepSeekUri('/chat/completions'),
      );
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      request.add(
        utf8.encode(
          jsonEncode({
            'model': EnvConfig.deepSeekModel,
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': maxTokens,
            if (responseFormat != null) 'response_format': responseFormat,
          }),
        ),
      );

      final response = await request.close().timeout(const Duration(seconds: 30));
      final responseText = await utf8.decodeStream(response);
      final decoded = responseText.isEmpty ? <String, dynamic>{} : jsonDecode(responseText);
      final data = decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = data['error'];
        if (error is Map && error['message'] != null) {
          throw AiAssistantException('AI could not answer yet: ${error['message']}');
        }
        throw const AiAssistantException(
          'AI could not answer yet. Please check the DeepSeek API key.',
        );
      }

      return data;
    } on SocketException {
      throw const AiAssistantException('I could not reach DeepSeek. Check your connection and API key.');
    } on TimeoutException {
      throw const AiAssistantException('DeepSeek took too long to respond. Try again in a moment.');
    } on FormatException catch (error) {
      throw AiAssistantException('AI returned an unreadable response: ${error.message}');
    } finally {
      client.close(force: true);
    }
  }

  Map<String, dynamic>? _decodeJsonObject(String content) {
    var text = content.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      text = text.replaceFirst(RegExp(r'\s*```$'), '');
    }

    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return null;
  }

  String _offlineReply(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('task') || lower.contains('todo')) {
      return 'I can add tasks now. Try: "Add a task to buy milk tomorrow."';
    }
    if (lower.contains('meal') || lower.contains('dinner')) {
      return 'Dinner idea: rice bowls with vegetables and protein. Add DEEPSEEK_API_KEY in .env for smarter replies.';
    }
    return 'Add DEEPSEEK_API_KEY in .env to turn on full AI replies. Task creation works now from chat.';
  }

  String? _greetingReply(String message) {
    final lower = message.trim().toLowerCase();
    const greetings = {'hi', 'hello', 'hey', 'yo', 'salam', 'السلام عليكم'};
    if (!greetings.contains(lower)) {
      return null;
    }

    return 'Hello! I am here. You can ask me to add a task, plan something, or help with family routines.';
  }

  Uri _deepSeekUri(String path) {
    final base = Uri.parse(EnvConfig.deepSeekBaseUrl);
    final cleanBasePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return base.replace(path: '$cleanBasePath$cleanPath');
  }

  String _friendlyDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(date.year, date.month, date.day);
    if (due == today) {
      return 'today';
    }
    if (due == today.add(const Duration(days: 1))) {
      return 'tomorrow';
    }

    return '${date.month}/${date.day}/${date.year}';
  }

  String _friendlyDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) {
      return 'today';
    }
    if (target == today.add(const Duration(days: 1))) {
      return 'tomorrow';
    }

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${date.month}/${date.day}/${date.year}';
  }

  String _formatClock(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static const Map<String, int> _weekdays = {
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };
}

class AiAssistantResult {
  final String reply;
  final bool taskCreated;
  final bool calendarEventCreated;

  const AiAssistantResult({
    required this.reply,
    this.taskCreated = false,
    this.calendarEventCreated = false,
  });
}

class AiAssistantException implements Exception {
  final String message;

  const AiAssistantException(this.message);

  @override
  String toString() => message;
}

class _TaskIntent {
  final String title;
  final String assignedToId;
  final String assignedToName;
  final DateTime dueDate;

  const _TaskIntent({
    required this.title,
    required this.assignedToId,
    required this.assignedToName,
    required this.dueDate,
  });
}

class _ParsedTime {
  final int hour;
  final int minute;

  const _ParsedTime({
    required this.hour,
    required this.minute,
  });
}

class _CalendarProposal {
  final String title;
  final DateTime start;
  final DateTime end;
  final bool hadGap;

  const _CalendarProposal({
    required this.title,
    required this.start,
    required this.end,
    required this.hadGap,
  });
}

class _CalendarSlot {
  final DateTime start;
  final DateTime end;

  const _CalendarSlot({
    required this.start,
    required this.end,
  });

  _CalendarSlot copyWith({
    DateTime? start,
    DateTime? end,
  }) {
    return _CalendarSlot(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}
