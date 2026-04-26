/// Family Member Model
class FamilyMember {
  final String id;
  final String name;
  final String? avatarUrl;
  final String role; // Mom, Dad, Child, etc.
  final int tasksCompleted;
  final int tasksPending;
  final bool isOnline;

  FamilyMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.tasksCompleted = 0,
    this.tasksPending = 0,
    this.isOnline = false,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString().trim();
    return FamilyMember(
      id: (json['userId'] ?? json['id'] ?? json['_id'])?.toString() ?? '',
      name: name == null || name.isEmpty ? 'Member' : name,
      avatarUrl: json['avatarUrl']?.toString(),
      role: json['role']?.toString() ?? 'Member',
      tasksCompleted: int.tryParse(json['tasksCompleted']?.toString() ?? '') ?? 0,
      tasksPending: int.tryParse(json['tasksPending']?.toString() ?? '') ?? 0,
      isOnline: _readOnlineStatus(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role,
      'tasksCompleted': tasksCompleted,
      'tasksPending': tasksPending,
      'isOnline': isOnline,
    };
  }

  static bool _readOnlineStatus(Map<String, dynamic> json) {
    final value = json['isOnline'] ?? json['online'] ?? json['is_active'] ?? json['isActive'];
    if (value is bool) {
      return value;
    }

    final text = (value ?? json['status'] ?? json['presence'])?.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'online' || text == 'active';
  }

  String get initials {
    if (name.trim().isEmpty) {
      return 'M';
    }

    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  int get totalTasks => tasksCompleted + tasksPending;

  double get completionRate {
    if (totalTasks == 0) return 0;
    return tasksCompleted / totalTasks;
  }
}
