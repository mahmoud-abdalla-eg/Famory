import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/calendar_event.dart';

/// A single event row showing time, color bar, title, and who.
class EventRowWidget extends StatelessWidget {
  final CalendarEvent event;

  const EventRowWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final parts = (event.time ?? '').split(' ');
    final who = event.who ?? 'All Members';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.g100)),
      ),
      child: Row(
        children: [
          // Time column
          SizedBox(
            width: 44,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(parts[0], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: event.color)),
                if (parts.length > 1)
                  Text(parts[1], style: const TextStyle(fontSize: 9, color: AppColors.g400)),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Color bar
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(color: event.color, borderRadius: BorderRadius.circular(100)),
          ),
          const SizedBox(width: 10),

          // Title + who
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.g800)),
                const SizedBox(height: 2),
                Text(who,   style: const TextStyle(fontSize: 11, color: AppColors.g400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
