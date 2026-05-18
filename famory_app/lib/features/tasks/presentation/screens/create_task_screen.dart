import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../family/data/models/family_member.dart';

class TaskFormData {
  final String title;
  final String assignedTo;
  final DateTime dueDate;
  final String description;

  const TaskFormData({
    required this.title,
    required this.assignedTo,
    required this.dueDate,
    this.description = '',
  });
}

class CreateTaskScreen extends StatefulWidget {
  final List<FamilyMember> members;
  final Future<void> Function(TaskFormData task) onTaskAdded;

  const CreateTaskScreen({
    super.key,
    required this.members,
    required this.onTaskAdded,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  late String _assignedTo;
  String _when = 'Today';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _assignedTo = widget.members
        .map((member) => member.id)
        .firstWhere((id) => id.isNotEmpty, orElse: () => '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.length < 3) {
      _showSnack('Task title must be at least 3 characters.');
      return;
    }

    if (_assignedTo.isEmpty) {
      _showSnack('Invite or load a family member before creating tasks.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onTaskAdded(
        TaskFormData(
          title: title,
          assignedTo: _assignedTo,
          dueDate: _dueDateFor(_when),
          description: _descriptionCtrl.text.trim(),
        ),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      _showSnack(_friendlyMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  DateTime _dueDateFor(String label) {
    final now = DateTime.now();
    switch (label) {
      case 'Tomorrow':
        return DateTime(now.year, now.month, now.day + 1, 18);
      case 'Fri':
        return _nextWeekday(DateTime.friday);
      case 'Mon':
        return _nextWeekday(DateTime.monday);
      case 'Today':
      default:
        return now.add(const Duration(hours: 2));
    }
  }

  DateTime _nextWeekday(int weekday) {
    final now = DateTime.now();
    var daysUntil = weekday - now.weekday;
    if (daysUntil <= 0) {
      daysUntil += 7;
    }
    final date = now.add(Duration(days: daysUntil));
    return DateTime(date.year, date.month, date.day, 18);
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
    final memberItems = widget.members
        .where((member) => member.id.isNotEmpty)
        .map(
          (member) => DropdownMenuItem<String>(
            value: member.id,
            child: Text(member.name),
          ),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Task',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.g900,
            ),
          ),
          const SizedBox(height: 14),
          _InputField(
            controller: _titleCtrl,
            hintText: 'Task title',
            autofocus: true,
          ),
          const SizedBox(height: 10),
          _InputField(
            controller: _descriptionCtrl,
            hintText: 'Description',
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Dropdown<String>(
                  value: memberItems.isEmpty ? null : _assignedTo,
                  hint: 'Assign to',
                  items: memberItems,
                  onChanged: (value) => setState(() => _assignedTo = value ?? ''),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Dropdown<String>(
                  value: _when,
                  items: const ['Today', 'Tomorrow', 'Fri', 'Mon']
                      .map((when) => DropdownMenuItem<String>(
                            value: when,
                            child: Text(when),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _when = value ?? 'Today'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Cancel',
                  backgroundColor: AppColors.g100,
                  foregroundColor: AppColors.g700,
                  onTap: _isSaving ? null : () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: _isSaving ? 'Saving...' : 'Add Task',
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  onTap: _isSaving ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool autofocus;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.autofocus = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppColors.g50,
        border: _border(AppColors.g200),
        enabledBorder: _border(AppColors.g200),
        focusedBorder: _border(AppColors.blue),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.g50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.g200, width: 1.5),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: hint == null ? null : Text(hint!),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.g500),
        style: const TextStyle(fontSize: 14, color: AppColors.g800),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: onTap == null ? backgroundColor.withValues(alpha: 0.55) : backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
