import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hatvest/core/theme/app_colors.dart';
import 'package:hatvest/core/theme/styles.dart';
import 'package:hatvest/core/theme/styles_manager.dart';
import 'package:hatvest/core/theme/font_manager.dart';
import 'package:hatvest/model/calendar_model.dart';
import 'package:hatvest/viewmodel/calendar_viewmodel.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<CalendarViewModel>();
      await vm.fetchEvents();
      if (vm.firstEventDate != null && mounted) {
        setState(() {
          _focusedMonth = DateTime(
            vm.firstEventDate!.year,
            vm.firstEventDate!.month,
          );
        });
      }
    });
  }

  List<CalendarEvent> _eventsForDay(
    List<CalendarEvent> all,
    int year,
    int month,
    int day,
  ) {
    return all.where((e) {
      try {
        final parts = e.date.split('-');
        if (parts.length < 3) return false;
        return int.parse(parts[0]) == year &&
            int.parse(parts[1]) == month &&
            int.parse(parts[2]) == day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  void _prevMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      });

  void _selectDay(int day) {
    setState(() {
      _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'calendar'.tr(),
          style: getBoldStyle(color: primaryColor, fontSize: FontSize.s20),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/picc1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Consumer<CalendarViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading && vm.events.isEmpty && vm.error == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final selectedEvents = CalendarEvent.sortedForDisplay(
                _eventsForDay(
                  vm.events,
                  _selectedDay.year,
                  _selectedDay.month,
                  _selectedDay.day,
                ),
              );

              return Column(
                children: [
                  if (vm.error != null) _CalendarErrorBanner(vm: vm),
                  const _CalendarLegend(),
                  Expanded(
                    flex: 5,
                    child: _CustomCalendarGrid(
                      focusedMonth: _focusedMonth,
                      selectedDay: _selectedDay,
                      events: vm.events,
                      onPrev: _prevMonth,
                      onNext: _nextMonth,
                      onDaySelected: _selectDay,
                      eventsForDay: _eventsForDay,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: _DayEventsPreview(
                      selectedDay: _selectedDay,
                      events: selectedEvents,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarErrorBanner extends StatelessWidget {
  final CalendarViewModel vm;

  const _CalendarErrorBanner({required this.vm});

  String _message() {
    switch (vm.error) {
      case 'unauthorized':
        return 'calendar_unauthorized'.tr();
      case 'fetch_failed':
        return 'calendar_fetch_failed'.tr();
      default:
        return 'calendar_error'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _message(),
              style: getMediumStyle(color: Colors.red.shade700, fontSize: FontSize.s12),
            ),
          ),
          TextButton(
            onPressed: vm.isLoading ? null : () => vm.fetchEvents(),
            child: Text('calendar_retry'.tr()),
          ),
        ],
      ),
    );
  }
}

// ─── Legend ─────────────────────────────────────────────────────────────────

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendChip(
            context,
            CalendarEventType.exam,
            'calendar_exams'.tr(),
          ),
          const SizedBox(width: 10),
          _legendChip(
            context,
            CalendarEventType.lecture,
            'calendar_lectures'.tr(),
          ),
          const SizedBox(width: 10),
          _legendChip(
            context,
            CalendarEventType.task,
            'calendar_tasks'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _legendChip(
    BuildContext context,
    CalendarEventType type,
    String label,
  ) {
    final style = CalendarEventTypeStyle.of(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.color.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.color),
          const SizedBox(width: 5),
          Text(
            label,
            style: getMediumStyle(color: style.color, fontSize: FontSize.s11),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Calendar Grid ────────────────────────────────────────────────────

class _CustomCalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<CalendarEvent> events;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onDaySelected;
  final List<CalendarEvent> Function(
    List<CalendarEvent>,
    int,
    int,
    int,
  ) eventsForDay;

  const _CustomCalendarGrid({
    required this.focusedMonth,
    required this.selectedDay,
    required this.events,
    required this.onPrev,
    required this.onNext,
    required this.onDaySelected,
    required this.eventsForDay,
  });

  static final DateTime _weekRefSaturday = DateTime(2024, 6, 1);

  List<String> _weekDayLabels(BuildContext context) {
    final locale = context.locale.languageCode;
    try {
      return List.generate(7, (i) {
        final day = _weekRefSaturday.add(Duration(days: i));
        return DateFormat.E(locale).format(day);
      });
    } catch (_) {
      return List.generate(7, (i) {
        final day = _weekRefSaturday.add(Duration(days: i));
        return DateFormat.E('en').format(day);
      });
    }
  }

  String _monthYearLabel(BuildContext context, DateTime month) {
    final locale = context.locale.languageCode;
    try {
      return DateFormat.yMMMM(locale).format(month);
    } catch (_) {
      return DateFormat.yMMMM('en').format(month);
    }
  }

  int _startOffset(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    return (firstDay.weekday + 1) % 7;
  }

  int _daysInMonth(DateTime month) =>
      DateTime(month.year, month.month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final weekDays = _weekDayLabels(context);
    final offset = _startOffset(focusedMonth);
    final daysCount = _daysInMonth(focusedMonth);
    final today = DateTime.now();
    final totalCells = offset + daysCount;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onPrev,
                icon: Icon(Icons.chevron_left, color: primaryColor),
              ),
              Text(
                _monthYearLabel(context, focusedMonth),
                style:
                    getBoldStyle(color: primaryColor, fontSize: FontSize.s16),
              ),
              IconButton(
                onPressed: onNext,
                icon: Icon(Icons.chevron_right, color: primaryColor),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: weekDays.asMap().entries.map((entry) {
              final i = entry.key;
              final d = entry.value;
              final isWeekend = i == 0 || i == 1;
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: getRegularStyle(
                      color: isWeekend ? Colors.red[400]! : context.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: List.generate(rows, (row) {
                return Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(7, (col) {
                      final cellIndex = row * 7 + col;
                      final day = cellIndex - offset + 1;
                      if (day < 1 || day > daysCount) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }

                      final isToday = today.year == focusedMonth.year &&
                          today.month == focusedMonth.month &&
                          today.day == day;
                      final isSelected = selectedDay.year == focusedMonth.year &&
                          selectedDay.month == focusedMonth.month &&
                          selectedDay.day == day;
                      final dayEvents = CalendarEvent.sortedForDisplay(
                        eventsForDay(
                          events,
                          focusedMonth.year,
                          focusedMonth.month,
                          day,
                        ),
                      );
                      final isWeekend = col == 0 || col == 1;

                      return Expanded(
                        child: _DayCell(
                          day: day,
                          isToday: isToday,
                          isSelected: isSelected,
                          isWeekend: isWeekend,
                          events: dayEvents,
                          onTap: () => onDaySelected(day),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Day Cell ────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isWeekend;
  final List<CalendarEvent> events;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isWeekend,
    required this.events,
    required this.onTap,
  });

  static const int _maxVisible = 2;

  Set<CalendarEventType> get _typesPresent =>
      events.map((e) => e.eventType).toSet();

  @override
  Widget build(BuildContext context) {
    final visibleEvents = events.take(_maxVisible).toList();
    final extra = events.length - _maxVisible;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.14)
              : Colors.white.withOpacity(0.82),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : isToday
                    ? primaryColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.55),
            width: isSelected ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: isToday
                  ? Center(
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: getBoldStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Text(
                      '$day',
                      style: getRegularStyle(
                        color: isWeekend
                            ? Colors.red[400]!
                            : context.textPrimary,
                        fontSize: 11,
                      ),
                    ),
            ),
            if (events.isNotEmpty) ...[
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Row(
                  children: [
                    if (_typesPresent.contains(CalendarEventType.exam))
                      _typeDot(CalendarEventType.exam),
                    if (_typesPresent.contains(CalendarEventType.lecture))
                      _typeDot(CalendarEventType.lecture),
                    if (_typesPresent.contains(CalendarEventType.task))
                      _typeDot(CalendarEventType.task),
                  ],
                ),
              ),
            ],
            ...visibleEvents.map((e) {
              final style = CalendarEventTypeStyle.of(e.eventType);
              final title = e.title.length > 9
                  ? '${e.title.substring(0, 9)}…'
                  : e.title;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: style.color,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    Icon(style.icon, size: 7, color: Colors.white),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7.5,
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (extra > 0)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 8,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _typeDot(CalendarEventType type) {
    final color = CalendarEventTypeStyle.of(type).color;
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─── Day Events Preview ────────────────────────────────────────────────────

class _DayEventsPreview extends StatelessWidget {
  final DateTime selectedDay;
  final List<CalendarEvent> events;

  const _DayEventsPreview({
    required this.selectedDay,
    required this.events,
  });

  String _formatDay(BuildContext context, DateTime day) {
    final locale = context.locale.languageCode;
    try {
      return DateFormat.yMMMd(locale).format(day);
    } catch (_) {
      return DateFormat.yMMMd('en').format(day);
    }
  }

  List<CalendarEvent> _ofType(CalendarEventType type) =>
      events.where((e) => e.eventType == type).toList();

  @override
  Widget build(BuildContext context) {
    final tasks = _ofType(CalendarEventType.task);
    final lectures = _ofType(CalendarEventType.lecture);
    final placementTests =
        events.where((e) => e.isPlacementTest).toList();
    final exams = events
        .where(
          (e) =>
              e.eventType == CalendarEventType.exam && !e.isPlacementTest,
        )
        .toList();
    final others = events
        .where(
          (e) =>
              e.eventType == CalendarEventType.other && !e.isPlacementTest,
        )
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(Icons.calendar_view_day, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'calendar_preview_title'.tr(),
                        style: getBoldStyle(
                          color: primaryColor,
                          fontSize: FontSize.s14,
                        ),
                      ),
                      Text(
                        _formatDay(context, selectedDay),
                        style: getRegularStyle(
                          color: context.textSecondary,
                          fontSize: FontSize.s12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${events.length}',
                    style: getBoldStyle(
                      color: primaryColor,
                      fontSize: FontSize.s12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: events.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'calendar_no_events'.tr(),
                        style: getRegularStyle(
                          color: context.textSecondary,
                          fontSize: FontSize.s14,
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    children: [
                      if (tasks.isNotEmpty)
                        _PreviewSection(
                          type: CalendarEventType.task,
                          title: 'calendar_tasks'.tr(),
                          events: tasks,
                        ),
                      if (lectures.isNotEmpty)
                        _PreviewSection(
                          type: CalendarEventType.lecture,
                          title: 'calendar_lectures'.tr(),
                          events: lectures,
                        ),
                      if (exams.isNotEmpty)
                        _PreviewSection(
                          type: CalendarEventType.exam,
                          title: 'calendar_exams'.tr(),
                          events: exams,
                        ),
                      if (others.isNotEmpty)
                        _PreviewSection(
                          type: CalendarEventType.other,
                          title: 'calendar_other'.tr(),
                          events: others,
                        ),
                      if (placementTests.isNotEmpty)
                        _PreviewSection(
                          type: CalendarEventType.other,
                          title: 'placement_test_title'.tr(),
                          events: placementTests,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final CalendarEventType type;
  final String title;
  final List<CalendarEvent> events;

  const _PreviewSection({
    required this.type,
    required this.title,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final style = CalendarEventTypeStyle.of(type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(style.icon, size: 16, color: style.color),
              const SizedBox(width: 6),
              Text(
                title,
                style: getBoldStyle(color: style.color, fontSize: FontSize.s13),
              ),
              const SizedBox(width: 6),
              Text(
                '(${events.length})',
                style: getRegularStyle(
                  color: context.textSecondary,
                  fontSize: FontSize.s12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...events.map((e) => _PreviewEventTile(event: e, type: type)),
        ],
      ),
    );
  }
}

class _PreviewEventTile extends StatelessWidget {
  final CalendarEvent event;
  final CalendarEventType type;

  const _PreviewEventTile({required this.event, required this.type});

  @override
  Widget build(BuildContext context) {
    final style = CalendarEventTypeStyle.of(type);
    final timeText = event.startTime.isNotEmpty
        ? (event.endTime.isNotEmpty
            ? '${event.startTime} - ${event.endTime}'
            : event.startTime)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: style.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: style.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: getBoldStyle(
                    color: context.textPrimary,
                    fontSize: FontSize.s13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (timeText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    timeText,
                    style: getRegularStyle(
                      color: context.textSecondary,
                      fontSize: FontSize.s11,
                    ),
                  ),
                ],
                if (event.instructor.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.instructor,
                    style: getRegularStyle(
                      color: context.textSecondary,
                      fontSize: FontSize.s11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
