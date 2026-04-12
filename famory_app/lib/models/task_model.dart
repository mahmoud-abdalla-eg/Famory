/// Task Model - Core data structure for task management
class TaskModel {
  final String id;
  final String title;
  final String assignedTo;
  final String assignedToAvatar;
  final DateTime dueDate;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? description;
  final TaskPriority priority;

  TaskModel({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.assignedToAvatar,
    required this.dueDate,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
    this.description,
    this.priority = TaskPriority.medium,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? assignedTo,
    String? assignedToAvatar,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? completedAt,
    String? description,
    TaskPriority? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToAvatar: assignedToAvatar ?? this.assignedToAvatar,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      description: description ?? this.description,
      priority: priority ?? this.priority,
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

    if (_isToday(tomorrow)) return 'Tomorrow';

    final difference = dueDate.difference(now).inDays;
    if (difference < 7) return 'In $difference days';

    return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
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
