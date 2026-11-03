import 'package:flutter/material.dart';
import '../engine/language.dart';

import '../l10n/calendar_labels.dart';
import '../theme/nepali_calendar_theme.dart';
import 'calendar_builders.dart';

/// The default day cell: a day number, selection/today/range decoration, a
/// weekend tint, and up to three event dots.
///
/// Used whenever the host does not supply a `dayBuilder` (or that builder
/// returns null for the day). The visual-priority order when several states
/// collide is: disabled → selected/range-endpoint → in-range → today → normal.
class NepaliDayCell extends StatelessWidget {
  /// Creates a day cell.
  const NepaliDayCell({
    super.key,
    required this.day,
    required this.language,
    required this.resolvedTheme,
  });

  /// The day's computed state.
  final NepaliDayContext day;

  /// Active language for numerals.
  final Language language;

  /// A theme already run through [NepaliCalendarTheme.resolve].
  final NepaliCalendarTheme resolvedTheme;

  @override
  Widget build(BuildContext context) {
    final t = resolvedTheme;

    Color? background;
    Color foreground;

    if (day.isSelected) {
      background = t.selectedDayBackgroundColor;
      foreground = t.selectedDayColor!;
    } else if (day.isInRange) {
      background = t.rangeHighlightColor;
      foreground = t.dayColor!;
    } else if (!day.isInMonth) {
      foreground = t.outsideMonthDayColor!;
    } else if (day.isDisabled) {
      foreground = t.disabledDayColor!;
    } else if (day.isToday) {
      foreground = t.todayColor!;
    } else if (day.isHoliday) {
      foreground = t.holidayColor!;
    } else if (day.isWeekend) {
      foreground = t.weekendLabelColor!;
    } else {
      foreground = t.dayColor!;
    }

    final showTodayBorder = day.isToday && !day.isSelected;

    final numeral = NepaliCalendarLabels.digits(day.date.day, language);

    final shape = t.cellShape;
    final decorated = Container(
      margin: const EdgeInsets.all(2),
      decoration: ShapeDecoration(
        color: background,
        shape: showTodayBorder
            ? (shape is OutlinedBorder
                ? shape.copyWith(
                    side: BorderSide(color: t.todayBorderColor!, width: 1.5),
                  )
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: t.todayBorderColor!, width: 1.5),
                  ))
            : (shape ??
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                )),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                numeral,
                style: (t.dayTextStyle ?? const TextStyle()).copyWith(
                  color: foreground,
                  fontWeight: day.isSelected || day.isToday
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
          if (day.events.isNotEmpty) _MarkerRow(day: day, theme: t),
        ],
      ),
    );

    return Semantics(
      label: _semanticLabel(numeral),
      selected: day.isSelected,
      button: !day.isDisabled,
      child: decorated,
    );
  }

  String _semanticLabel(String numeral) {
    final parts = <String>['Day ${day.date.day}'];
    if (day.isToday) parts.add('today');
    if (day.isSelected) parts.add('selected');
    if (day.isWeekend) parts.add('Saturday');
    if (day.isDisabled) parts.add('unavailable');
    for (final e in day.events) {
      parts.add(e.title);
    }
    return parts.join(', ');
  }
}

class _MarkerRow extends StatelessWidget {
  const _MarkerRow({required this.day, required this.theme});

  final NepaliDayContext day;
  final NepaliCalendarTheme theme;

  @override
  Widget build(BuildContext context) {
    final shown = day.events.take(3).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final event in shown)
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: event.color ??
                    (event.isHoliday ? theme.holidayColor : theme.markerColor),
              ),
            ),
        ],
      ),
    );
  }
}
