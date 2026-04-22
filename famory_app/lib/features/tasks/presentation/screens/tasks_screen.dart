import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/task_item.dart';
import 'create_task_screen.dart';
import '../widgets/task_item_widget.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late List<TaskItem> todayTasks;
  late List<TaskItem> upcomingTasks;

  @override
  void initState() {
    super.initState();
    todayTasks = [
      TaskItem(id: 'tk1', title: 'Grocery shopping',  subtitle: 'Sarah · Due today',    pillText: 'Today', pillColor: const Color(0xFFC2410C), pillBg: AppColors.orangeL),
      TaskItem(id: 'tk2', title: 'School pickup 3pm', subtitle: 'James · Recurring',    pillText: 'Rec',   pillColor: AppColors.blueD,          pillBg: AppColors.blueL),
      TaskItem(id: 'tk3', title: 'Morning dishes',    subtitle: 'Emma · Completed',     pillText: 'Done',  pillColor: AppColors.greenD,          pillBg: AppColors.greenL, isDone: true),
    ];
    upcomingTasks = [
      TaskItem(id: 'tk4', title: 'Pay electricity bill', subtitle: 'Sarah · Due Friday', pillText: 'Fri', pillColor: const Color(0xFFDC2626), pillBg: AppColors.redL),
      TaskItem(id: 'tk5', title: 'Car service appt',     subtitle: 'James · Due Monday', pillText: 'Mon', pillColor: AppColors.g500,            pillBg: AppColors.g100),
    ];
  }

  // ── Computed counts ─────────────────────────────────────────────────────────
  int get _openCount    => (todayTasks + upcomingTasks).where((t) => !t.isDone).length;
  int get _doneCount    => (todayTasks + upcomingTasks).where((t) =>  t.isDone).length;
  int get _overdueCount => 3;

  // ── Toggle task done/undone ─────────────────────────────────────────────────
  void _toggleTask(TaskItem task) {
    setState(() {
      task.isDone = !task.isDone;
      if (task.isDone) {
        task.pillText  = 'Done';
        task.pillColor = AppColors.greenD;
        task.pillBg    = AppColors.greenL;
      } else {
        task.pillText  = 'Today';
        task.pillColor = const Color(0xFFC2410C);
        task.pillBg    = AppColors.orangeL;
      }
    });
  }

  // ── Open Add Task bottom sheet ──────────────────────────────────────────────
  void _showAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateTaskScreen(
        onTaskAdded: (task) => setState(() => todayTasks.add(task)),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: AppColors.blue,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  Text('9:41', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  GestureDetector(
                    onTap: _showAddTask,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('+ Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
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

  // ── Scrollable body ─────────────────────────────────────────────────────────
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsRow(),
          const SizedBox(height: 14),
          _buildSectionTitle('Today'),
          ...todayTasks.map((t) => TaskItemWidget(task: t, onToggle: () => _toggleTask(t))),
          const SizedBox(height: 8),
          _buildSectionTitle('Upcoming'),
          ...upcomingTasks.map((t) => TaskItemWidget(task: t, onToggle: () => _toggleTask(t))),
          const SizedBox(height: 16),
          _buildSectionTitle('Workload'),
          _buildWorkloadCard(),
        ],
      ),
    );
  }

  // ── Stats row ───────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatBox(value: _openCount.toString(),    label: 'Open',    numColor: AppColors.blue,              bgColor: AppColors.blueL,  labelColor: AppColors.blueD),
        const SizedBox(width: 8),
        _StatBox(value: _doneCount.toString(),    label: 'Done',    numColor: AppColors.greenD,            bgColor: AppColors.greenL, labelColor: AppColors.greenD),
        const SizedBox(width: 8),
        _StatBox(value: _overdueCount.toString(), label: 'Overdue', numColor: const Color(0xFFDC2626), bgColor: AppColors.redL,   labelColor: const Color(0xFFDC2626)),
      ],
    );
  }

  // ── Section title ───────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.g400, letterSpacing: 0.6),
      ),
    );
  }

  // ── Workload card ───────────────────────────────────────────────────────────
  Widget _buildWorkloadCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.g200),
      ),
      child: const Column(
        children: [
          _WorkloadBar(name: 'Sarah', tasks: '8 tasks', color: AppColors.blue,   percent: 0.8),
          SizedBox(height: 9),
          _WorkloadBar(name: 'James', tasks: '5 tasks', color: AppColors.orange, percent: 0.5),
          SizedBox(height: 9),
          _WorkloadBar(name: 'Emma',  tasks: '3 tasks', color: AppColors.green,  percent: 0.3),
        ],
      ),
    );
  }
}

// ── Private sub-widgets (small, scoped to this file) ───────────────────────────

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color numColor;
  final Color bgColor;
  final Color labelColor;

  const _StatBox({
    required this.value,
    required this.label,
    required this.numColor,
    required this.bgColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: numColor)),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: labelColor)),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g700)),
            Text(tasks, style: const TextStyle(fontSize: 11, color: AppColors.g400)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(100)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(100))),
          ),
        ),
      ],
    );
  }
}
