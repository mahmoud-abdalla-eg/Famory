/// Family Member Model
class FamilyMember {
  final String id;
  final String name;
  final String? avatarUrl;
  final String role; // Mom, Dad, Child, etc.
  final int tasksCompleted;
  final int tasksPending;

  FamilyMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.tasksCompleted = 0,
    this.tasksPending = 0,
  });

  String get initials {
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
