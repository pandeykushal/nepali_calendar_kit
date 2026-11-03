import 'package:flutter/material.dart';
import '../engine/language.dart';
import '../engine/nepali_date.dart';

import '../core/date_range.dart';
import '../models/calendar_event.dart';
import '../models/selection_mode.dart';
import '../theme/nepali_calendar_theme.dart';
import 'nepali_calendar.dart';

/// Material dialog body wrapping a [NepaliCalendar] with Cancel / OK actions.
///
/// Returned value depends on [selectionMode]: a [NepaliDate] for single
/// selection, a [NepaliDateRange] for range selection, or null if cancelled.
class NepaliDatePickerDialog extends StatefulWidget {
  /// Creates the dialog body.
  const NepaliDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.initialRange,
    this.selectionMode = NepaliSelectionMode.single,
    this.disabledDates,
    this.selectableDayPredicate,
    this.events,
    this.theme,
    this.language,
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
    this.showAdDate = true,
  });

  /// Date the calendar opens on.
  final NepaliDate initialDate;

  /// Earliest selectable date.
  final NepaliDate? firstDate;

  /// Latest selectable date.
  final NepaliDate? lastDate;

  /// Pre-selected range for range mode.
  final NepaliDateRange? initialRange;

  /// Single vs range.
  final NepaliSelectionMode selectionMode;

  /// Specific disabled dates.
  final Set<NepaliDate>? disabledDates;

  /// Extra per-day gate.
  final bool Function(NepaliDate date)? selectableDayPredicate;

  /// Markers to render.
  final Map<NepaliDate, List<CalendarEvent>>? events;

  /// Visual overrides.
  final NepaliCalendarTheme? theme;

  /// Active language.
  final Language? language;

  /// Confirm button label.
  final String confirmText;

  /// Cancel button label.
  final String cancelText;

  /// Show the AD subtitle.
  final bool showAdDate;

  @override
  State<NepaliDatePickerDialog> createState() => _NepaliDatePickerDialogState();
}

class _NepaliDatePickerDialogState extends State<NepaliDatePickerDialog> {
  NepaliDate? _single;
  NepaliDateRange? _range;

  @override
  void initState() {
    super.initState();
    if (widget.selectionMode == NepaliSelectionMode.range) {
      _range = widget.initialRange;
    } else {
      _single = widget.initialDate;
    }
  }

  bool get _hasSelection => widget.selectionMode == NepaliSelectionMode.range
      ? _range != null
      : _single != null;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: NepaliCalendar(
                    initialDate: widget.initialDate,
                    selectedDate:
                        widget.selectionMode == NepaliSelectionMode.single
                            ? _single
                            : null,
                    selectedRange:
                        widget.selectionMode == NepaliSelectionMode.range
                            ? _range
                            : null,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate,
                    selectionMode: widget.selectionMode,
                    disabledDates: widget.disabledDates,
                    selectableDayPredicate: widget.selectableDayPredicate,
                    events: widget.events,
                    theme: widget.theme,
                    language: widget.language,
                    showAdDate: widget.showAdDate,
                    onDateChanged: (d) => setState(() => _single = d),
                    onRangeChanged: (r) => setState(() => _range = r),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(widget.cancelText),
                  ),
                  FilledButton(
                    onPressed: _hasSelection
                        ? () => Navigator.of(context).pop(
                              widget.selectionMode == NepaliSelectionMode.range
                                  ? _range
                                  : _single,
                            )
                        : null,
                    child: Text(widget.confirmText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
