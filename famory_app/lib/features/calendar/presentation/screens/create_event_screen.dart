import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/event_service.dart';

/// Bottom sheet shown when the user taps "+ Event" on the Calendar screen.
/// Calls [onEventAdded] with the new [CalendarEventModel] when confirmed.
class CreateEventScreen extends StatefulWidget {
  final DateTime selectedDate;
  final EventService? eventService;

  const CreateEventScreen({
    super.key,
    required this.selectedDate,
    this.eventService,
  });

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleCtrl = TextEditingController();
  final _timeCtrl  = TextEditingController();
  String _who = 'All Members';

  static const _whoOptions = ['All Members', 'Sarah', 'James', 'Emma', 'Liam'];
  static const _eventColors = [
    AppColors.blue, AppColors.green, AppColors.orange, AppColors.purple, AppColors.teal,
  ];

  late final EventService _eventService;

  @override
  void initState() {
    super.initState();
    _eventService = widget.eventService ?? EventService();
    _timeCtrl.text = '9:00 AM';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) { Navigator.pop(context); return; }

    final time = _timeCtrl.text.trim().isNotEmpty ? _timeCtrl.text.trim() : '12:00 PM'; 
      // Requires refinement on input validation, this is not enough

    _eventService.addEvent(
      CalendarEventModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        date: DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
        ),
        time: time,
        startTime: time,
        who: _who,
        color: _eventColors[0], // use a default color since there's no color picker yet
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18, right: 18, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Event',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.g900),
          ),
          const SizedBox(height: 14),

          // Event title
          _InputField(controller: _titleCtrl, hint: 'Event title', autofocus: true),
          const SizedBox(height: 10),

          // Time + Who row
          Row(
            children: [
              Expanded(child: _InputField(controller: _timeCtrl, hint: '9:00 AM')),
              const SizedBox(width: 8),
              Expanded(
                child: _WhoDropdown(
                  value: _who,
                  items: _whoOptions,
                  onChanged: (v) => setState(() => _who = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Cancel / Add Event
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: AppColors.g100, borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.g700)),
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
                    decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Text('Add Event', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
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

// ── Private helpers (scoped to this file) ──────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool autofocus;

  const _InputField({required this.controller, required this.hint, this.autofocus = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.g400, fontSize: 13),
        filled: true,
        fillColor: AppColors.g50,
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.g200, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.g200, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.blue,  width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _WhoDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _WhoDropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
        style: const TextStyle(fontSize: 13, color: AppColors.g800),
        items: items.map((w) => DropdownMenuItem<String>(value: w, child: Text(w))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
