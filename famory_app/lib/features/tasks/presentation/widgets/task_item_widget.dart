import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/task_item.dart';

/// A single interactive task row with an animated checkbox and pill badge.
class TaskItemWidget extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggle;

  const TaskItemWidget({
    super.key,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: task.isDone ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.g200),
          ),
          child: Row(
            children: [
              // Animated checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: task.isDone ? AppColors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: task.isDone ? AppColors.green : AppColors.g300,
                    width: 2,
                  ),
                ),
                child: task.isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 13)
                    : null,
              ),
              const SizedBox(width: 10),

              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: task.isDone ? AppColors.g400 : AppColors.g800,
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.g400),
                    ),
                  ],
                ),
              ),

              // Pill badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: task.pillBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  task.pillText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: task.pillColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
