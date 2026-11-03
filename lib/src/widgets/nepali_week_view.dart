import 'package:flutter/material.dart';

import '../core/nepali_date_utils.dart';
import '../engine/language.dart';
import '../engine/nepali_date.dart';
import '../l10n/calendar_labels.dart';
import '../models/calendar_event.dart';
import '../theme/nepali_calendar_theme.dart';

/// A single-week strip (Sunday → Saturday) containing [anchor], with optional
/// event dots and tap selection. Useful as a compact header or an agenda top.
class NepaliWeekView extends StatelessWidget {
  /// Creates a week view for the week containing [anchor].
  const NepaliWeekView({
    super.key,
    required this.anchor,
    this.selected,
    this.events,
    this.onDateSelected,
    this.language = Language.english,
    this.theme,
  });

  /// Any date in the week to display.
  final NepaliDate anchor;

  /// Currently selected day (highlighted).
  final NepaliDate? selected;

  /// Events keyed by day (for the dot).
  final Map<NepaliDate, List<CalendarEvent>>? events;

  /// Tapped a day.
  final void Function(NepaliDate date)? onDateSelected;

  /// Language for numerals/labels.
  final Language language;

  /// Visual overrides.
  final NepaliCalendarTheme? theme;

  @override
  Widget build(BuildContext context) {
    final t = (theme ?? const NepaliCalendarTheme()).resolve(context);
    final start = anchor.subtract(Duration(days: anchor.weekday - 1));
    final headers = NepaliCalendarLabels.weekdayHeaders(language);

    return Row(
      children: List<Widget>.generate(7, (i) {
        final day = start.add(Duration(days: i));
        final isSel =
            selected != null && NepaliDateUtils.isSameDay(selected!, day);
        final isToday = NepaliDateUtils.isSameDay(NepaliDateUtils.today(), day);
        final hasEvents =
            (events?[NepaliDateUtils.dateOnly(day)] ?? const []).isNotEmpty ||
                (events != null &&
                    events!.keys.any((k) => NepaliDateUtils.isSameDay(k, day)));
        return Expanded(
          child: InkWell(
            onTap: onDateSelected == null ? null : () => onDateSelected!(day),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    headers[i],
                    style: t.weekdayTextStyle?.copyWith(
                      color: i == 6 ? t.weekendLabelColor : t.weekdayLabelColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSel ? t.selectedDayBackgroundColor : null,
                      border: isToday && !isSel
                          ? Border.all(color: t.todayBorderColor!, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      NepaliCalendarLabels.digits(day.day, language),
                      style: TextStyle(
                        color: isSel ? t.selectedDayColor : t.dayColor,
                        fontWeight: isSel || isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    height: 5,
                    child: hasEvents
                        ? Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: t.markerColor,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
