import 'package:flutter/material.dart';

import '../core/nepali_date_utils.dart';
import '../core/nepali_month_grid.dart';
import '../engine/language.dart';
import '../engine/nepali_date.dart';
import '../l10n/calendar_labels.dart';
import '../theme/nepali_calendar_theme.dart';
import 'weekday_header.dart';

/// A month calendar whose day cells are shaded by a per-day value - a
/// contribution/activity heatmap (think streak trackers).
class NepaliHeatmapCalendar extends StatelessWidget {
  /// Creates a heatmap for [month] using [values] (keyed by day).
  const NepaliHeatmapCalendar({
    super.key,
    required this.month,
    required this.values,
    this.maxValue,
    this.baseColor,
    this.language = Language.english,
    this.theme,
    this.onDateTap,
  });

  /// Any date in the month to display.
  final NepaliDate month;

  /// Per-day intensity values (0 or absent = empty).
  final Map<NepaliDate, num> values;

  /// Value treated as full intensity. Defaults to the maximum in [values].
  final num? maxValue;

  /// Color ramped by alpha for intensity. Defaults to the theme primary.
  final Color? baseColor;

  /// Language for numerals.
  final Language language;

  /// Visual overrides.
  final NepaliCalendarTheme? theme;

  /// Tapped a day.
  final void Function(NepaliDate date, num value)? onDateTap;

  num _lookup(NepaliDate d) {
    for (final entry in values.entries) {
      if (NepaliDateUtils.isSameDay(entry.key, d)) return entry.value;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = (theme ?? const NepaliCalendarTheme()).resolve(context);
    final base = baseColor ?? Theme.of(context).colorScheme.primary;
    final grid = NepaliMonthGrid(month.year, month.month);
    final max = (maxValue ??
            (values.values.isEmpty
                ? 1
                : values.values.reduce((a, b) => a > b ? a : b)))
        .toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NepaliWeekdayHeader(language: language, resolvedTheme: t),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: grid.days.length,
          itemBuilder: (context, i) {
            final cell = grid.days[i];
            final value = cell.inMonth ? _lookup(cell.date) : 0;
            final intensity = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
            final fill = cell.inMonth
                ? base.withValues(alpha: 0.12 + 0.88 * intensity)
                : Colors.transparent;
            return InkWell(
              onTap: (!cell.inMonth || onDateTap == null)
                  ? null
                  : () => onDateTap!(cell.date, value),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: value > 0
                      ? fill
                      : (cell.inMonth
                          ? base.withValues(alpha: 0.06)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  cell.inMonth
                      ? NepaliCalendarLabels.digits(cell.date.day, language)
                      : '',
                  style: TextStyle(
                    fontSize: 11,
                    color: intensity > 0.5
                        ? Theme.of(context).colorScheme.onPrimary
                        : t.dayColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
