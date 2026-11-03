import 'package:flutter/material.dart';

import '../engine/language.dart';
import '../engine/nepali_date.dart';
import '../theme/nepali_calendar_theme.dart';
import 'show_nepali_date_picker.dart';

/// Picks a BS **date and time** together: first the date (via
/// [showNepaliDatePicker]), then the time (via Flutter's [showTimePicker]).
///
/// Returns a [NepaliDate] carrying the chosen `hour`/`minute`, or null if the
/// user cancels either step.
Future<NepaliDate?> showNepaliDateTimePicker({
  required BuildContext context,
  NepaliDate? initialDate,
  NepaliDate? firstDate,
  NepaliDate? lastDate,
  NepaliDatePickerStyle style = NepaliDatePickerStyle.adaptive,
  Language? language,
  NepaliCalendarTheme? theme,
}) async {
  final date = await showNepaliDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    style: style,
    language: language,
    theme: theme,
  );
  if (date == null) return null;
  if (!context.mounted) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: initialDate?.hour ?? 0,
      minute: initialDate?.minute ?? 0,
    ),
  );
  if (time == null) {
    return date;
  }
  return NepaliDate(date.year, date.month, date.day, time.hour, time.minute);
}
