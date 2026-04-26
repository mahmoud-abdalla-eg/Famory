import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/calendar_event.dart';
import '../../data/services/event_service.dart';
import '../screens/create_event_screen.dart';

/// A single event row showing time, color bar, title, and who.
class EventRowWidget extends StatefulWidget {
  final CalendarEventModel event;
  final EventService? eventService;

  const EventRowWidget({
    super.key,
    required this.event,
    this.eventService,
  });

  @override
  State<EventRowWidget> createState() => _EventRowWidgetState();
}

class _EventRowWidgetState extends State<EventRowWidget>
    with SingleTickerProviderStateMixin {
  static const double _swipeTriggerFraction = 0.32;
  static const double _maxSwipeFraction = 0.55;
  static const Duration _snapBackDuration = Duration(milliseconds: 260);
  static const Duration _dismissDuration = Duration(milliseconds: 180);

  late final AnimationController _offsetController;
  double _rowWidth = 1;
  bool _isHandlingAction = false;

  CalendarEventModel get _event => widget.event;
  EventService get _events => widget.eventService ?? EventService();
  double get _dragOffset => _offsetController.value;

  @override
  void initState() {
    super.initState();
    _offsetController = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _offsetController.dispose();
    super.dispose();
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: Text('Delete "${_event.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateEventScreen(
        selectedDate: _event.date ?? DateTime.now(),
        eventService: widget.eventService,
        initialEvent: _event,
      ),
    );
  }

  double _clampOffset(double offset) {
    final maxOffset = _rowWidth * _maxSwipeFraction;
    return offset.clamp(-maxOffset, maxOffset);
  }

  Future<void> _animateOffset(
    double target, {
    required Duration duration,
    Curve curve = Curves.easeOutCubic,
  }) {
    _offsetController.stop();
    return _offsetController.animateTo(
      target,
      duration: duration,
      curve: curve,
    );
  }

  Future<void> _animateBack() {
    return _animateOffset(
      0,
      duration: _snapBackDuration,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleDragEnd(BuildContext context) async {
    if (_isHandlingAction) return;

    final triggerOffset = _rowWidth * _swipeTriggerFraction;
    if (_dragOffset.abs() < triggerOffset) {
      await _animateBack();
      return;
    }

    _isHandlingAction = true;
    try {
      if (_dragOffset > 0) {
        await _animateOffset(
          _rowWidth,
          duration: _dismissDuration,
          curve: Curves.easeOut,
        );
        await _showEditSheet(context);
        await _animateBack();
        return;
      }

      await _animateOffset(
        -_rowWidth,
        duration: _dismissDuration,
        curve: Curves.easeOut,
      );
      final confirmed = await _confirmDelete(context) ?? false;
      if (!confirmed) {
        await _animateBack();
        return;
      }

      final eventId = _event.id;
      if (eventId == null) {
        await _animateBack();
        return;
      }

      _events.removeEvent(eventId);
    } finally {
      _isHandlingAction = false;
    }
  }

  Widget _buildSwipeBackground() {
    final isEdit = _dragOffset > 0;
    final isDelete = _dragOffset < 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isEdit
            ? AppColors.orange
            : isDelete
                ? AppColors.red
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: isEdit ? 1 : 0,
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: isDelete ? 1 : 0,
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parts = (_event.time ?? _event.startTime ?? '').split(' ');
    final who = _event.who ?? 'All Members';

    return LayoutBuilder(
      builder: (context, constraints) {
        _rowWidth = constraints.maxWidth;

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(child: _buildSwipeBackground()),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) {
                  _offsetController.stop();
                },
                onHorizontalDragUpdate: (details) {
                  if (_isHandlingAction) return;
                  _offsetController.value =
                      _clampOffset(_dragOffset + details.delta.dx);
                },
                onHorizontalDragEnd: (_) => _handleDragEnd(context),
                onHorizontalDragCancel: () {
                  _animateBack();
                },
                child: Transform.translate(
                  offset: Offset(_dragOffset, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: AppColors.g100),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                parts[0],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _event.color,
                                ),
                              ),
                              if (parts.length > 1)
                                Text(
                                  parts[1],
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.g400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 3,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _event.color,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _event.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.g800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                who,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.g400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
