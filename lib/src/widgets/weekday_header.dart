import 'package:flutter/material.dart';
import '../engine/language.dart';

import '../l10n/calendar_labels.dart';
import '../theme/nepali_calendar_theme.dart';

/// The row of weekday labels (Sun → Sat) above the day grid.
class NepaliWeekdayHeader extends StatelessWidget {
  /// Creates the weekday header.
  const NepaliWeekdayHeader({
    super.key,
    required this.language,
    required this.resolvedTheme,
  });

  /// Language driving the labels.
  final Language language;

  /// A theme already run through [NepaliCalendarTheme.resolve].
  final NepaliCalendarTheme resolvedTheme;

  @override
  Widget build(BuildContext context) {
    final labels = NepaliCalendarLabels.weekdayHeaders(language);
    return Row(
      children: List<Widget>.generate(7, (i) {
        final isWeekend = i == 6;
        return Expanded(
          child: Center(
            child: Text(
              labels[i],
              semanticsLabel: NepaliCalendarLabels.weekdayHeadersEn[i],
              style: resolvedTheme.weekdayTextStyle?.copyWith(
                color: isWeekend
                    ? resolvedTheme.weekendLabelColor
                    : resolvedTheme.weekdayLabelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}
