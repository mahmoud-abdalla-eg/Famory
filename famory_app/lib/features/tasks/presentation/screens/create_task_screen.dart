import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/task_item.dart';

/// Bottom sheet shown when the user taps "+ Add" on the Tasks screen.
/// Calls [onTaskAdded] with the new [TaskItem] when confirmed.
class CreateTaskScreen extends StatefulWidget {
  final void Function(TaskItem task) onTaskAdded;

  const CreateTaskScreen({super.key, required this.onTaskAdded});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleCtrl = TextEditingController();
  String _who = 'Sarah';
  String _when = 'Today';

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      Navigator.pop(context);
      return;
    }
    widget.onTaskAdded(
      TaskItem(
        id: 'tk${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subtitle: '$_who · Due $_when',
        pillText: _when,
        pillColor: const Color(0xFFC2410C),
        pillBg: AppColors.orangeL,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.g900),
          ),
          const SizedBox(height: 14),

          // Title input
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Task title',
              filled: true,
              fillColor: AppColors.g50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.g200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.g200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),

          // Who + When dropdowns
          Row(
            children: [
              Expanded(
                child: _Dropdown(
                  value: _who,
                  items: const ['Sarah', 'James', 'Emma', 'Liam'],
                  onChanged: (v) => setState(() => _who = v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Dropdown(
                  value: _when,
                  items: const ['Today', 'Tomorrow', 'Fri', 'Mon'],
                  onChanged: (v) => setState(() => _when = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Cancel / Add Task buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.g100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.g700),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Add Task',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Private helper dropdown widget ─────────────────────────────────────────────
class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
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
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.g500),
        style: const TextStyle(fontSize: 14, color: AppColors.g800),
        items: items
            .map((w) => DropdownMenuItem<String>(value: w, child: Text(w)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
