import 'package:flutter/material.dart';
import '../engine/language.dart';
import '../engine/nepali_date.dart';

import '../l10n/calendar_labels.dart';
import '../theme/nepali_calendar_theme.dart';

/// Default header: ‹ prev - "Month Year" (tappable for quick jump) - next ›.
class NepaliCalendarHeader extends StatelessWidget {
  /// Creates the header.
  const NepaliCalendarHeader({
    super.key,
    required this.visibleMonth,
    required this.language,
    required this.resolvedTheme,
    required this.onPrevious,
    required this.onNext,
    required this.onTapTitle,
    required this.canGoPrevious,
    required this.canGoNext,
  });

  /// Month currently displayed (day is ignored).
  final NepaliDate visibleMonth;

  /// Active language.
  final Language language;

  /// Resolved theme.
  final NepaliCalendarTheme resolvedTheme;

  /// Tapped the ‹ arrow.
  final VoidCallback? onPrevious;

  /// Tapped the › arrow.
  final VoidCallback? onNext;

  /// Tapped the title (used to open the year/month jump sheet).
  final VoidCallback onTapTitle;

  /// Whether paging back is allowed (false disables the ‹ arrow).
  final bool canGoPrevious;

  /// Whether paging forward is allowed (false disables the › arrow).
  final bool canGoNext;

  @override
  Widget build(BuildContext context) {
    final t = resolvedTheme;
    final monthName =
        NepaliCalendarLabels.monthName(visibleMonth.month, language);
    final year = NepaliCalendarLabels.digits(visibleMonth.year, language);

    return Container(
      color: t.headerBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: t.headerForegroundColor,
            onPressed: canGoPrevious ? onPrevious : null,
            tooltip: 'Previous month',
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTapTitle,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$monthName $year',
                          style: t.headerTextStyle?.copyWith(
                            color: t.headerForegroundColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: t.headerForegroundColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: t.headerForegroundColor,
            onPressed: canGoNext ? onNext : null,
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }
}

/// A modal that lets the user jump straight to a year + month.
///
/// Returns the chosen first-of-month [NepaliDate], or null if dismissed.
Future<NepaliDate?> showNepaliMonthYearPicker({
  required BuildContext context,
  required NepaliDate initialMonth,
  required int minYear,
  required int maxYear,
  required Language language,
}) {
  return showModalBottomSheet<NepaliDate>(
    context: context,
    showDragHandle: true,
    builder: (context) => _MonthYearJumpSheet(
      initialMonth: initialMonth,
      minYear: minYear,
      maxYear: maxYear,
      language: language,
    ),
  );
}

class _MonthYearJumpSheet extends StatefulWidget {
  const _MonthYearJumpSheet({
    required this.initialMonth,
    required this.minYear,
    required this.maxYear,
    required this.language,
  });

  final NepaliDate initialMonth;
  final int minYear;
  final int maxYear;
  final Language language;

  @override
  State<_MonthYearJumpSheet> createState() => _MonthYearJumpSheetState();
}

class _MonthYearJumpSheetState extends State<_MonthYearJumpSheet> {
  late int _year = widget.initialMonth.year;
  late int _month = widget.initialMonth.month;

  @override
  Widget build(BuildContext context) {
    final years = <int>[
      for (var y = widget.minYear; y <= widget.maxYear; y++) y,
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Jump to', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _year,
                    decoration: const InputDecoration(labelText: 'Year'),
                    items: <DropdownMenuItem<int>>[
                      for (final y in years)
                        DropdownMenuItem<int>(
                          value: y,
                          child: Text(
                            NepaliCalendarLabels.digits(y, widget.language),
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() => _year = v ?? _year),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _month,
                    decoration: const InputDecoration(labelText: 'Month'),
                    items: <DropdownMenuItem<int>>[
                      for (var m = 1; m <= 12; m++)
                        DropdownMenuItem<int>(
                          value: m,
                          child: Text(
                            NepaliCalendarLabels.monthName(m, widget.language),
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() => _month = v ?? _month),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  NepaliDate(_year, _month),
                ),
                child: const Text('Go'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
