import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/task_model.dart';
import '../models/family_member.dart';
import '../widgets/custom_avatar.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_button.dart';

/// Enhanced Task Management Screen with Full CRUD Operations - FIXED
class TasksScreenEnhanced extends StatefulWidget {
  final VoidCallback onBack;

  const TasksScreenEnhanced({super.key, required this.onBack});

  @override
  State<TasksScreenEnhanced> createState() => _TasksScreenEnhancedState();
}

class _TasksScreenEnhancedState extends State<TasksScreenEnhanced>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock family members
  final List<FamilyMember> familyMembers = [
    FamilyMember(id: '1', name: 'Sarah Miller', role: 'Daughter', tasksPending: 2, tasksCompleted: 3),
    FamilyMember(id: '2', name: 'Mom', role: 'Mother', tasksPending: 1, tasksCompleted: 4),
    FamilyMember(id: '3', name: 'Dad', role: 'Father', tasksPending: 1, tasksCompleted: 2),
    FamilyMember(id: '4', name: 'Jake', role: 'Son', tasksPending: 0, tasksCompleted: 1),
  ];

  // Mock tasks data
  List<TaskModel> tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeTasks();
  }

  void _initializeTasks() {
    tasks = [
      TaskModel(
        id: '1',
        title: 'Take out trash',
        assignedTo: 'Sarah Miller',
        assignedToAvatar: 'Sarah',
        dueDate: DateTime.now(),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: '2',
        title: 'Buy groceries',
        assignedTo: 'Mom',
        assignedToAvatar: 'Mom',
        dueDate: DateTime.now().add(const Duration(hours: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Milk, eggs, bread, and fruits',
      ),
      TaskModel(
        id: '3',
        title: 'Pick up dry cleaning',
        assignedTo: 'Dad',
        assignedToAvatar: 'Dad',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      ),
      TaskModel(
        id: '4',
        title: 'Water plants',
        assignedTo: 'Sarah Miller',
        assignedToAvatar: 'Sarah',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TaskModel(
        id: '5',
        title: 'Call grandma',
        assignedTo: 'Mom',
        assignedToAvatar: 'Mom',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleTask(String taskId) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        tasks[index] = tasks[index].copyWith(
          isCompleted: !tasks[index].isCompleted,
          completedAt: !tasks[index].isCompleted ? DateTime.now() : null,
        );
      }
    });
  }

  void _deleteTask(String taskId) {
    setState(() {
      tasks.removeWhere((t) => t.id == taskId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  void _addTask(TaskModel task) {
    setState(() {
      tasks.insert(0, task);
    });
  }

  void _showAddTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskModal(
        familyMembers: familyMembers,
        onTaskAdded: _addTask,
      ),
    );
  }

  List<TaskModel> get activeTasks => tasks.where((t) => !t.isCompleted).toList();
  List<TaskModel> get completedTasks => tasks.where((t) => t.isCompleted).toList();

  double get completionRate {
    if (tasks.isEmpty) return 0;
    return completedTasks.length / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxl + AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            child: Column(
              children: [
                // Title & Back
                Row(
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
                    Text(
                      'Tasks',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Progress Overview
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Family Progress',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: AppColors.successGreen),
                          ),
                          Text(
                            '${completedTasks.length}/${tasks.length} completed',
                            style: Theme.of(context)
                                .textTheme.bodySmall
                                ?.copyWith(color: AppColors.successGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: completionRate,
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.successGreen,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Tabs
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryBlue,
                  indicatorWeight: 3,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: Theme.of(context).textTheme.labelMedium,
                  tabs: [
                    Tab(text: 'To Do (${activeTasks.length})'),
                    Tab(text: 'Completed (${completedTasks.length})'),
                  ],
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Tasks Tab
                activeTasks.isEmpty
                    ? EmptyState(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'All caught up!',
                        description: 'No pending tasks. Great work, family!',
                        actionLabel: 'Add New Task',
                        onAction: _showAddTaskModal,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: activeTasks.length,
                        itemBuilder: (context, index) {
                          return TaskCard(
                            task: activeTasks[index],
                            onToggle: _toggleTask,
                            onDelete: _deleteTask,
                          );
                        },
                      ),

                // Completed Tasks Tab
                completedTasks.isEmpty
                    ? const EmptyState(
                        icon: Icons.task_alt_rounded,
                        title: 'No completed tasks',
                        description: 'Completed tasks will appear here',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: completedTasks.length,
                        itemBuilder: (context, index) {
                          return TaskCard(
                            task: completedTasks[index],
                            onToggle: _toggleTask,
                            onDelete: _deleteTask,
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskModal,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Task Card Widget
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final Function(String) onToggle;
  final Function(String) onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(task.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => onToggle(task.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? AppColors.successGreen
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColors.successGreen
                        : AppColors.borderGray,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Task Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      task.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      CustomAvatar(
                        name: task.assignedToAvatar,
                        size: AvatarSize.small,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        task.assignedTo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '•',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: task.isOverdue
                              ? AppColors.error.withValues(alpha: 0.1)
                              : task.isDueToday
                                  ? AppColors.warning.withValues(alpha: 0.1)
                                  : AppColors.softBlueBg,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          task.dueDateFormatted,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: task.isOverdue
                                        ? AppColors.error
                                        : task.isDueToday
                                            ? AppColors.warning
                                            : AppColors.textSecondary,
                                  ),
                        ),
                      ),
                    ],
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

/// Add Task Modal - Bottom Sheet
class AddTaskModal extends StatefulWidget {
  final List<FamilyMember> familyMembers;
  final void Function(TaskModel) onTaskAdded;

  const AddTaskModal({
    super.key,
    required this.familyMembers,
    required this.onTaskAdded,
  });

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  FamilyMember? _selectedMember;
  DateTime _selectedDate = DateTime.now();
  final TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _createTask() {
    if (_formKey.currentState!.validate() && _selectedMember != null) {
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        assignedTo: _selectedMember!.name,
        assignedToAvatar: _selectedMember!.name,
        dueDate: _selectedDate,
        createdAt: DateTime.now(),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        priority: _selectedPriority,
      );

      widget.onTaskAdded(task);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task assigned to ${_selectedMember!.name}'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } else if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a family member'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderGray,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  'Add New Task',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Task Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'e.g., Take out trash',
                    filled: true,
                    fillColor: AppColors.bgMain,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Description (Optional)
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Add more details...',
                    filled: true,
                    fillColor: AppColors.bgMain,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Assign To
                Text(
                  'Assign To',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: widget.familyMembers.map((member) {
                    final isSelected = _selectedMember?.id == member.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMember = member;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.softBlueBg,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomAvatar(
                              name: member.name,
                              size: AvatarSize.small,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              member.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),

                // Due Date
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.bgMain,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Date',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Cancel',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => Navigator.pop(context),
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        text: 'Create Task',
                        onPressed: _createTask,
                        isExpanded: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
