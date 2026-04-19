import 'package:flutter/material.dart';
import '../../../../theme.dart';
import '../../data/services/event_service.dart';
import '../../data/models/calendar_event.dart';

class CalendarScreenEnhanced extends StatefulWidget {
  final VoidCallback onBack;

  const CalendarScreenEnhanced({super.key, required this.onBack});

  @override
  State<CalendarScreenEnhanced> createState() => _CalendarScreenEnhancedState();
}

class _CalendarScreenEnhancedState extends State<CalendarScreenEnhanced> {
  final EventService _eventService = EventService();
  late DateTime selectedDate;
  late int currentYear;
  late int currentMonth;

  final List<String> daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _eventService.initializeSampleEvents();
    _eventService.addListener(_onEventsChanged);

    final now = DateTime.now();
    currentYear = now.year;
    currentMonth = now.month;
    selectedDate = DateTime(now.year, now.month, 11); // Default selected date
  }

  @override
  void dispose() {
    _eventService.removeListener(_onEventsChanged);
    super.dispose();
  }

  void _onEventsChanged() {
    setState(() {});
  }

  void _previousMonth() {
    setState(() {
      if (currentMonth == 1) {
        currentMonth = 12;
        currentYear--;
      } else {
        currentMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (currentMonth == 12) {
        currentMonth = 1;
        currentYear++;
      } else {
        currentMonth++;
      }
    });
  }

  void _showAddEventModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEventModal(
        selectedDate: selectedDate,
        onEventAdded: (event) {
          _eventService.addEvent(event);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event added successfully!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsOnSelectedDate = _eventService.getEventsForDate(selectedDate);
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: Column(
        children: [
          _buildHeader(),
          _buildCalendarGrid(daysInMonth),
          _buildEventsList(eventsOnSelectedDate),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventModal,
        backgroundColor: AppColors.accentOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Event', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xxl + AppSpacing.md, AppSpacing.lg, AppSpacing.md),
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
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: AppColors.deepBlue, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'Calendar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${monthNames[currentMonth - 1]} $currentYear',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _previousMonth,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.softBlueBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.chevron_left_rounded, color: AppColors.deepBlue, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _nextMonth,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.softBlueBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.chevron_right_rounded, color: AppColors.deepBlue, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(int daysInMonth) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek.map((day) => SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(daysInMonth, (index) {
              final day = index + 1;
              final date = DateTime(currentYear, currentMonth, day);
              final hasEvent = _eventService.hasEventsOnDate(date);
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFFF8C42), Color(0xFFE67A3A)],
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
                          color: isSelected ? Colors.white : AppColors.textPrimary,
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
    );
  }

  Widget _buildEventsList(List<CalendarEventModel> events) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            events.isEmpty
                ? 'NO EVENTS'
                : 'EVENTS ON ${monthNames[selectedDate.month - 1].toUpperCase()} ${selectedDate.day}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...events.map((event) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border(left: BorderSide(color: event.color, width: 4)),
                  boxShadow: AppShadows.soft,
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
                      event.timeRange,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    if (event.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.description!,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Add Event Modal
class AddEventModal extends StatefulWidget {
  final DateTime selectedDate;
  final Function(CalendarEventModel) onEventAdded;

  const AddEventModal({
    super.key,
    required this.selectedDate,
    required this.onEventAdded,
  });

  @override
  State<AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  late DateTime selectedDate;
  Color selectedColor = AppColors.primaryBlue;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      final event = CalendarEventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        date: selectedDate,
        startTime: _startTimeController.text.isEmpty ? null : _startTimeController.text,
        endTime: _endTimeController.text.isEmpty ? null : _endTimeController.text,
        color: selectedColor,
      );

      widget.onEventAdded(event);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const Text('Add New Event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.lg),

                // Event Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                    hintText: 'e.g., Doctor Appointment',
                    filled: true,
                    fillColor: AppColors.bgMain,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)), borderSide: BorderSide.none),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter event title' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    filled: true,
                    fillColor: AppColors.bgMain,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Date
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
                        const Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Time
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(_startTimeController),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _startTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                              filled: true,
                              fillColor: AppColors.bgMain,
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(_endTimeController),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              filled: true,
                              fillColor: AppColors.bgMain,
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Color Selection
                const Text('Event Color', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    AppColors.primaryBlue,
                    AppColors.accentOrange,
                    AppColors.successGreen,
                    const Color(0xFF8B5CF6),
                  ].map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSelected ? [const BoxShadow(color: Colors.black26, blurRadius: 8)] : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.softBlueBg,
                          foregroundColor: AppColors.deepBlue,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _createEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
                        ),
                        child: const Text('Create Event'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
