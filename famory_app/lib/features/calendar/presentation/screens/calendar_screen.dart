import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/calendar_event.dart';
import 'create_event_screen.dart';
import '../widgets/event_row_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _calYear;
  late int _calMonth; // 0-based
  late int _selDay;

  late Map<String, List<CalendarEvent>> _events;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  static const _dayAbbr  = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  static const _eventColors = [
    AppColors.blue, AppColors.green, AppColors.orange, AppColors.purple, AppColors.teal,
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calYear  = now.year;
    _calMonth = now.month - 1;
    _selDay   = now.day;

    _events = {
      _key(now.year, now.month - 1, now.day): [
        const CalendarEvent(title: 'Doctor appointment',  time: '9:00 AM',  who: 'Sarah',       color: AppColors.blue),
        const CalendarEvent(title: 'School pickup',       time: '3:00 PM',  who: 'James',       color: AppColors.green),
        const CalendarEvent(title: 'Family dinner',       time: '6:30 PM',  who: 'All Members', color: AppColors.orange),
      ],
      _key(now.year, now.month - 1, now.day + 3): [
        const CalendarEvent(title: 'Emma soccer practice', time: '4:00 PM', who: 'Emma',        color: AppColors.orange),
      ],
      _key(now.year, now.month - 1, now.day + 7): [
        const CalendarEvent(title: 'Family movie night',   time: '7:00 PM', who: 'All Members', color: AppColors.purple),
      ],
      _key(now.year, now.month - 1, now.day + 14): [
        const CalendarEvent(title: 'Liam birthday party',  time: '2:00 PM', who: 'All Members', color: AppColors.red),
      ],
    };
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  static String _key(int y, int m, int d) => '$y-$m-$d';

  List<CalendarEvent> get _selectedEvents =>
      _events[_key(_calYear, _calMonth, _selDay)] ?? [];

  void _changeMonth(int dir) {
    setState(() {
      _calMonth += dir;
      if (_calMonth > 11) { _calMonth = 0; _calYear++; }
      else if (_calMonth < 0) { _calMonth = 11; _calYear--; }
      _selDay = 1;
    });
  }

  // ── Add event bottom sheet ───────────────────────────────────────────────────
  void _showAddEvent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateEventScreen(
        onEventAdded: (ev) {
          final key = _key(_calYear, _calMonth, _selDay);
          setState(() {
            if (!_events.containsKey(key)) _events[key] = [];
            final idx = _events[key]!.length;
            // Pick rotating color based on event count
            _events[key]!.add(CalendarEvent(
              title: ev.title,
              time:  ev.time ?? '12:00 PM',
              who:   ev.who ?? 'All Members',
              color: _eventColors[idx % _eventColors.length],
            ));
          });
        },
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final now          = DateTime.now();
    final firstWeekday = DateTime(_calYear, _calMonth + 1, 1).weekday % 7;
    final daysInMonth  = DateTime(_calYear, _calMonth + 2, 0).day;
    final selDateStr   = '${_dayNames[DateTime(_calYear, _calMonth + 1, _selDay).weekday % 7]}, ${_months[_calMonth]} $_selDay';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendarCard(now, firstWeekday, daysInMonth),
                  const SizedBox(height: 14),
                  _buildDayBar(selDateStr),
                  const SizedBox(height: 10),
                  _buildEventsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
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
                  Text('${_months[_calMonth]} $_calYear',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  Row(
                    children: [
                      _NavBtn(icon: Icons.chevron_left,  onTap: () => _changeMonth(-1)),
                      const SizedBox(width: 4),
                      _NavBtn(icon: Icons.chevron_right, onTap: () => _changeMonth(1)),
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

  // ── Calendar grid card ────────────────────────────────────────────────────────
  Widget _buildCalendarCard(DateTime now, int firstWeekday, int daysInMonth) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.g200),
      ),
      child: Column(
        children: [
          // Day-of-week headers
          Row(
            children: _dayAbbr.map((d) => Expanded(
              child: Center(
                child: Text(d, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.g400)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 6),

          // Date grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 1.0, mainAxisSpacing: 2, crossAxisSpacing: 2,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (_, index) {
              if (index < firstWeekday) return const SizedBox();
              final day = index - firstWeekday + 1;
              final hasEvent = (_events[_key(_calYear, _calMonth, day)] ?? []).isNotEmpty;
              final isToday    = now.year == _calYear && now.month - 1 == _calMonth && now.day == day;
              final isSelected = _selDay == day && !isToday;

              return GestureDetector(
                onTap: () => setState(() => _selDay = day),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.blue : isSelected ? AppColors.blueL : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                          color: isToday ? Colors.white : isSelected ? AppColors.blueD : AppColors.g600,
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4, height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday ? Colors.white.withValues(alpha: 0.7) : AppColors.blue,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Day label + "+ Event" button ──────────────────────────────────────────────
  Widget _buildDayBar(String selDateStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          selDateStr.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.g400, letterSpacing: 0.6),
        ),
        GestureDetector(
          onTap: _showAddEvent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(9)),
            child: const Text('+ Event', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ── Events list or empty state ────────────────────────────────────────────────
  Widget _buildEventsList() {
    if (_selectedEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: const Text(
          'No events — tap + Event to add one',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.g400),
        ),
      );
    }
    return Column(
      children: _selectedEvents.map((ev) => EventRowWidget(event: ev)).toList(),
    );
  }
}

// ── Private sub-widget ─────────────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
