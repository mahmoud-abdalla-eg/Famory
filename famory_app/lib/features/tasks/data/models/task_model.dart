/// Task Model - Core data structure for task management
class TaskModel {
  final String id;
  final String? familyId;
  final String title;
  final String assignedTo;
  final String assignedToId;
  final String assignedToAvatar;
  final DateTime dueDate;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? description;
  final TaskPriority priority;
  final String status;
  final String? createdBy;

  TaskModel({
    required this.id,
    this.familyId,
    required this.title,
    required this.assignedTo,
    String? assignedToId,
    required this.assignedToAvatar,
    required this.dueDate,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
    this.description,
    this.priority = TaskPriority.medium,
    this.status = 'todo',
    this.createdBy,
  }) : assignedToId = assignedToId ?? assignedTo;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? 'todo';
    final dueDate = _readDate(json['dueDate']) ?? DateTime.now();
    final createdAt = _readDate(json['createdAt']) ?? DateTime.now();
    return TaskModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      familyId: json['familyId']?.toString(),
      title: json['title']?.toString() ?? 'Untitled task',
      assignedTo: json['assignedTo']?.toString() ?? '',
      assignedToId: json['assignedTo']?.toString() ?? '',
      assignedToAvatar: '',
      dueDate: dueDate,
      createdAt: createdAt,
      isCompleted: status == 'done',
      completedAt: status == 'done' ? _readDate(json['updatedAt']) : null,
      description: json['description']?.toString(),
      priority: TaskPriority.medium,
      status: status,
      createdBy: json['createdBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'description': description,
      'assignedTo': assignedToId,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': completedAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? familyId,
    String? title,
    String? assignedTo,
    String? assignedToId,
    String? assignedToAvatar,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? completedAt,
    String? description,
    TaskPriority? priority,
    String? status,
    String? createdBy,
  }) {
    return TaskModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      title: title ?? this.title,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToAvatar: assignedToAvatar ?? this.assignedToAvatar,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  bool get isOverdue =>
      !isCompleted && DateTime.now().isAfter(dueDate) && !_isToday(dueDate);

  bool get isDueToday => _isToday(dueDate);

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String get dueDateFormatted {
    if (isOverdue) return 'Overdue';
    if (isDueToday) return 'Due Today';

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day) {
      return 'Tomorrow';
    }

    final difference = dueDate.difference(now).inDays;
    if (difference < 7) return 'In $difference days';

    return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  }

  static DateTime? _readDate(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text)?.toLocal();
  }
}

enum TaskPriority { low, medium, high, urgent }

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}
