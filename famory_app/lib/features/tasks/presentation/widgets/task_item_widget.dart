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
        opacity: task.isDone ? 0.62 : 1.0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.g200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: task.isDone ? 0.02 : 0.045),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: task.isDone ? AppColors.green : AppColors.g50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: task.isDone ? AppColors.green : AppColors.g300,
                    width: 2,
                  ),
                ),
                child: task.isDone
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 17)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                        color: task.isDone ? AppColors.g400 : AppColors.g800,
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      task.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.g400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: task.pillBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  task.pillText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
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
