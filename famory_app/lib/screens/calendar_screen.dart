import 'package:flutter/material.dart';
import '../theme.dart';

class CalendarEvent {
  final int id;
  final String title;
  final String time;
  final int day;
  final Color color;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.time,
    required this.day,
    required this.color,
  });
}

class CalendarScreen extends StatefulWidget {
  final VoidCallback onBack;

  const CalendarScreen({super.key, required this.onBack});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int selectedDay = 11;

  final List<CalendarEvent> events = [
    CalendarEvent(
      id: 1,
      title: 'Soccer Practice',
      time: '4:00 PM - 5:30 PM',
      day: 11,
      color: AppColors.accentOrange,
    ),
    CalendarEvent(
      id: 2,
      title: 'Family Dinner',
      time: '6:30 PM - 8:00 PM',
      day: 11,
      color: AppColors.successGreen,
    ),
    CalendarEvent(
      id: 3,
      title: 'Parent-Teacher Meeting',
      time: '3:00 PM - 4:00 PM',
      day: 13,
      color: AppColors.primaryBlue,
    ),
    CalendarEvent(
      id: 4,
      title: 'Dentist Appointment',
      time: '10:00 AM - 11:00 AM',
      day: 15,
      color: AppColors.accentOrange,
    ),
  ];

  final List<String> daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final todayEvents = events.where((e) => e.day == selectedDay).toList();

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.softBlueBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.deepBlue,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Calendar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'April 2026',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.softBlueBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.deepBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.softBlueBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.deepBlue,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calendar Grid
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              children: [
                // Days of week
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: daysOfWeek.map((day) {
                    return SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // Calendar days
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(30, (index) {
                    final day = index + 1;
                    final hasEvent = events.any((e) => e.day == day);
                    final isSelected = day == selectedDay;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDay = day;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFF8C42),
                                    Color(0xFFE67A3A),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (hasEvent && !isSelected)
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  todayEvents.isEmpty
                      ? 'NO EVENTS'
                      : 'EVENTS ON APRIL $selectedDay',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...todayEvents.map((event) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border(
                          left: BorderSide(
                            color: event.color,
                            width: 4,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.time,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
