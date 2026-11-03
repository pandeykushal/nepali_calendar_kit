import 'package:flutter/widgets.dart';
import '../engine/nepali_date.dart';

import '../models/calendar_event.dart';

/// Visual + logical state passed to a [NepaliDayBuilder].
class NepaliDayContext {
  /// Creates a day context. Normally constructed by the calendar, not callers.
  const NepaliDayContext({
    required this.date,
    required this.isInMonth,
    required this.isToday,
    required this.isSelected,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isInRange,
    required this.isDisabled,
    required this.isWeekend,
    required this.isHoliday,
    required this.events,
  });

  /// The date this cell represents.
  final NepaliDate date;

  /// Whether [date] belongs to the month on screen (vs an adjacent-month
  /// filler cell).
  final bool isInMonth;

  /// Whether [date] is today.
  final bool isToday;

  /// Whether [date] is the (single) selected day or a range endpoint.
  final bool isSelected;

  /// Whether [date] is the start of the selected range.
  final bool isRangeStart;

  /// Whether [date] is the end of the selected range.
  final bool isRangeEnd;

  /// Whether [date] lies strictly inside the selected range.
  final bool isInRange;

  /// Whether [date] is unselectable (outside min/max or explicitly disabled).
  final bool isDisabled;

  /// Whether [date] is a Saturday.
  final bool isWeekend;

  /// Whether any event on [date] is marked `isHoliday`.
  final bool isHoliday;

  /// Events/markers registered for [date] (never null; may be empty).
  final List<CalendarEvent> events;
}

/// Builds a fully custom day cell. Return null to fall back to the default
/// cell for a given day.
typedef NepaliDayBuilder = Widget? Function(
  BuildContext context,
  NepaliDayContext day,
);

/// Builds a fully custom month/year header. Return null to use the default
/// header.
typedef NepaliHeaderBuilder = Widget? Function(
  BuildContext context,
  NepaliDate visibleMonth,
);

/// Called when the single-date selection changes.
typedef NepaliDateChanged = void Function(NepaliDate date);
