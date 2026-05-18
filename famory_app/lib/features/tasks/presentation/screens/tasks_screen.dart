import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../family/data/models/family_member.dart';
import '../../../family/data/services/family_service.dart';
import '../../data/models/task_item.dart';
import '../../data/models/task_model.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_item_widget.dart';
import 'create_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskController _controller = TaskController();
  final FamilyService _familyService = FamilyService();

  bool _isLoading = false;
  String? _errorMessage;

  List<TaskModel> get _tasks => _controller.tasks.toList();
  List<TaskModel> get _todayTasks =>
      _tasks.where((task) => task.isDueToday || task.isOverdue).toList();
  List<TaskModel> get _upcomingTasks =>
      _tasks.where((task) => !task.isDueToday && !task.isOverdue).toList();

  int get _openCount => _tasks.where((task) => !task.isCompleted).length;
  int get _doneCount => _tasks.where((task) => task.isCompleted).length;
  int get _overdueCount => _tasks.where((task) => task.isOverdue).length;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final familyId = _familyService.familyId;
    if (familyId == null || familyId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Create or join a family before using tasks.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _controller.loadTasks(familyId);
    } catch (error) {
      _errorMessage = _friendlyMessage(error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleTask(TaskModel task) async {
    try {
      await _controller.setTaskDone(task, !task.isCompleted);
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      _showSnack(_friendlyMessage(error));
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    try {
      await _controller.deleteTask(task.id);
      if (mounted) {
        setState(() {});
        _showSnack('Task deleted');
      }
    } catch (error) {
      _showSnack(_friendlyMessage(error));
    }
  }

  void _showAddTask() {
    final familyId = _familyService.familyId;
    if (familyId == null || familyId.isEmpty) {
      _showSnack('Create or join a family before adding tasks.');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateTaskScreen(
        members: _familyService.members,
        onTaskAdded: (task) async {
          await _controller.createTask(
            familyId: familyId,
            title: task.title,
            assignedTo: task.assignedTo,
            dueDate: task.dueDate,
            description: task.description,
          );
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.g50,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTask,
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.blue))
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _ErrorState(message: _errorMessage!, onRetry: _loadTasks);
    }

    return RefreshIndicator(
      color: AppColors.blue,
      onRefresh: _loadTasks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            const SizedBox(height: 16),
            _buildSectionTitle('Today'),
            if (_todayTasks.isEmpty)
              const _EmptyTaskSection(
                icon: Icons.wb_sunny_outlined,
                text: 'Nothing urgent today.',
                subtext: 'Enjoy the rare quiet moment.',
              )
            else
              ..._todayTasks.map(
                (task) => _DismissibleTask(
                  taskId: task.id,
                  onDelete: () => _deleteTask(task),
                  child: TaskItemWidget(
                    task: _taskItemFor(task),
                    onToggle: () => _toggleTask(task),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            _buildSectionTitle('Upcoming'),
            if (_upcomingTasks.isEmpty)
              const _EmptyTaskSection(
                icon: Icons.auto_awesome_outlined,
                text: 'No upcoming tasks.',
                subtext: 'Add something when the family needs it.',
              )
            else
              ..._upcomingTasks.map(
                (task) => _DismissibleTask(
                  taskId: task.id,
                  onDelete: () => _deleteTask(task),
                  child: TaskItemWidget(
                    task: _taskItemFor(task),
                    onToggle: () => _toggleTask(task),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            _buildSectionTitle('Workload'),
            _buildWorkloadCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    final completion = _tasks.isEmpty ? 0.0 : _doneCount / _tasks.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.g200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.blueL,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.task_alt_rounded, color: AppColors.blue, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Tasks',
                        style: TextStyle(
                          color: AppColors.g900,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Keep chores light, clear, and fair.',
                        style: TextStyle(
                          color: AppColors.g500,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: completion.clamp(0, 1).toDouble(),
                minHeight: 7,
                backgroundColor: AppColors.g100,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _HeroMetric(
                  value: _openCount.toString(),
                  label: 'Open',
                  icon: Icons.radio_button_unchecked,
                  color: AppColors.blueD,
                  bgColor: AppColors.blueL,
                ),
                const SizedBox(width: 8),
                _HeroMetric(
                  value: _doneCount.toString(),
                  label: 'Done',
                  icon: Icons.check_circle_outline,
                  color: AppColors.greenD,
                  bgColor: AppColors.greenL,
                ),
                const SizedBox(width: 8),
                _HeroMetric(
                  value: _overdueCount.toString(),
                  label: 'Late',
                  icon: Icons.timer_outlined,
                  color: AppColors.red,
                  bgColor: AppColors.redL,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 9),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.g400,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _buildWorkloadCard() {
    final members = _familyService.members;
    if (members.isEmpty) {
      return const _EmptyTaskSection(
        icon: Icons.groups_2_outlined,
        text: 'Family members will appear here.',
        subtext: 'Invite them to balance tasks.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.g200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < members.length; index++) ...[
            _WorkloadBar(
              name: members[index].name,
              tasks: '${_taskCountFor(members[index])} tasks',
              color: _memberColor(index),
              percent: _workloadPercent(members[index]),
            ),
            if (index != members.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  TaskItem _taskItemFor(TaskModel task) {
    final isDone = task.isCompleted;
    final isOverdue = task.isOverdue;
    final assigneeName = _memberName(task.assignedToId);
    final pillText = isDone
        ? 'Done'
        : isOverdue
            ? 'Late'
            : task.isDueToday
                ? 'Today'
                : _shortDueLabel(task.dueDate);

    return TaskItem(
      id: task.id,
      title: task.title,
      subtitle: '$assigneeName - ${task.dueDateFormatted}',
      pillText: pillText,
      pillColor: isDone
              ? AppColors.greenD
              : isOverdue
                  ? const Color(0xFFDC2626)
                  : AppColors.blueD,
      pillBg: isDone
          ? AppColors.greenL
          : isOverdue
              ? AppColors.redL
              : AppColors.blueL,
      isDone: isDone,
    );
  }

  String _memberName(String userId) {
    for (final member in _familyService.members) {
      if (member.id == userId) {
        return member.name;
      }
    }

    return 'Family member';
  }

  int _taskCountFor(FamilyMember member) {
    return _tasks.where((task) => task.assignedToId == member.id && !task.isCompleted).length;
  }

  double _workloadPercent(FamilyMember member) {
    final maxCount = _familyService.members
        .map(_taskCountFor)
        .fold<int>(0, (max, count) => count > max ? count : max);
    if (maxCount == 0) {
      return 0;
    }

    return _taskCountFor(member) / maxCount;
  }

  Color _memberColor(int index) {
    const colors = [
      AppColors.blue,
      AppColors.orange,
      AppColors.green,
      AppColors.teal,
      AppColors.purple,
    ];

    return colors[index % colors.length];
  }

  String _shortDueLabel(DateTime dueDate) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[dueDate.weekday - 1];
  }
}

class _DismissibleTask extends StatelessWidget {
  final String taskId;
  final Future<void> Function() onDelete;
  final Widget child;

  const _DismissibleTask({
    required this.taskId,
    required this.onDelete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('task-$taskId'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        await onDelete();
        return true;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
      ),
      child: child,
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _HeroMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkloadBar extends StatelessWidget {
  final String name;
  final String tasks;
  final Color color;
  final double percent;

  const _WorkloadBar({
    required this.name,
    required this.tasks,
    required this.color,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color.withValues(alpha: 0.14),
              child: Text(
                name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.g800,
                ),
              ),
            ),
            Text(
              tasks,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.g400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.g100,
            borderRadius: BorderRadius.circular(100),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent.clamp(0, 1).toDouble(),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyTaskSection extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtext;

  const _EmptyTaskSection({
    required this.icon,
    required this.text,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.g200),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.blueL,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.g800,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: const TextStyle(
                    color: AppColors.g400,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_late_outlined, color: AppColors.g400, size: 34),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.g600,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
