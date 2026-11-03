import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import '../engine/language.dart';
import '../engine/nepali_date.dart';

import '../core/date_range.dart';
import '../core/nepali_date_utils.dart';
import '../models/calendar_event.dart';
import '../models/selection_mode.dart';
import '../theme/nepali_calendar_theme.dart';
import 'cupertino_nepali_date_picker.dart';
import 'nepali_date_picker_dialog.dart';

/// Which visual style a picker should present with.
enum NepaliDatePickerStyle {
  /// Material grid dialog.
  material,

  /// iOS-style wheel.
  cupertino,

  /// Pick automatically from the platform (`defaultTargetPlatform`).
  adaptive,
}

/// Shows a Bikram Sambat **single-date** picker and resolves to the chosen
/// date, or null if dismissed.
///
/// Mirrors the shape of Flutter's `showDatePicker` so it feels instantly
/// familiar. By default it adapts to the platform: a Material grid dialog on
/// Android/others, a Cupertino wheel on iOS. Force one with [style].
Future<NepaliDate?> showNepaliDatePicker({
  required BuildContext context,
  NepaliDate? initialDate,
  NepaliDate? firstDate,
  NepaliDate? lastDate,
  NepaliDatePickerStyle style = NepaliDatePickerStyle.adaptive,
  Set<NepaliDate>? disabledDates,
  bool Function(NepaliDate date)? selectableDayPredicate,
  Map<NepaliDate, List<CalendarEvent>>? events,
  NepaliCalendarTheme? theme,
  Language? language,
  bool showAdDate = true,
  String confirmText = 'OK',
  String cancelText = 'Cancel',
}) {
  final anchor = NepaliDateUtils.clamp(
    initialDate ?? NepaliDateUtils.today(),
    min: firstDate,
    max: lastDate,
  );

  final resolvedStyle = _resolveStyle(style);

  if (resolvedStyle == NepaliDatePickerStyle.cupertino) {
    return _showCupertino(
      context: context,
      initialDate: anchor,
      firstDate: firstDate,
      lastDate: lastDate,
      language: language,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  return showDialog<NepaliDate>(
    context: context,
    builder: (context) => NepaliDatePickerDialog(
      initialDate: anchor,
      firstDate: firstDate,
      lastDate: lastDate,
      disabledDates: disabledDates,
      selectableDayPredicate: selectableDayPredicate,
      events: events,
      theme: theme,
      language: language,
      showAdDate: showAdDate,
      confirmText: confirmText,
      cancelText: cancelText,
    ),
  );
}

/// Shows a Bikram Sambat **range** picker and resolves to the chosen range, or
/// null if dismissed. Always uses the Material dialog (ranges don't map to a
/// wheel).
Future<NepaliDateRange?> showNepaliDateRangePicker({
  required BuildContext context,
  NepaliDateRange? initialRange,
  NepaliDate? firstDate,
  NepaliDate? lastDate,
  Set<NepaliDate>? disabledDates,
  bool Function(NepaliDate date)? selectableDayPredicate,
  Map<NepaliDate, List<CalendarEvent>>? events,
  NepaliCalendarTheme? theme,
  Language? language,
  String confirmText = 'OK',
  String cancelText = 'Cancel',
}) {
  final anchor = NepaliDateUtils.clamp(
    initialRange?.start ?? NepaliDateUtils.today(),
    min: firstDate,
    max: lastDate,
  );
  return showDialog<NepaliDateRange>(
    context: context,
    builder: (context) => NepaliDatePickerDialog(
      initialDate: anchor,
      initialRange: initialRange,
      selectionMode: NepaliSelectionMode.range,
      firstDate: firstDate,
      lastDate: lastDate,
      disabledDates: disabledDates,
      selectableDayPredicate: selectableDayPredicate,
      events: events,
      theme: theme,
      language: language,
      confirmText: confirmText,
      cancelText: cancelText,
    ),
  );
}

NepaliDatePickerStyle _resolveStyle(NepaliDatePickerStyle style) {
  if (style != NepaliDatePickerStyle.adaptive) return style;
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS =>
      NepaliDatePickerStyle.cupertino,
    _ => NepaliDatePickerStyle.material,
  };
}

Future<NepaliDate?> _showCupertino({
  required BuildContext context,
  required NepaliDate initialDate,
  NepaliDate? firstDate,
  NepaliDate? lastDate,
  Language? language,
  required String confirmText,
  required String cancelText,
}) {
  var current = initialDate;
  return showModalBottomSheet<NepaliDate>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(cancelText),
              ),
              CupertinoButton(
                onPressed: () => Navigator.of(context).pop(current),
                child: Text(confirmText),
              ),
            ],
          ),
          CupertinoNepaliDatePicker(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            language: language,
            onDateChanged: (d) => current = d,
          ),
        ],
      ),
    ),
  );
}
