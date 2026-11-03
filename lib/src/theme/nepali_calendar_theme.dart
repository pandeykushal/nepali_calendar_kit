import 'package:flutter/material.dart';

/// Visual configuration for the calendar widgets.
///
/// Every color and text style is optional. Anything left null is resolved from
/// the ambient [ThemeData] / [ColorScheme] at build time via [resolve], so the
/// calendar adopts the host app's Material 3 theme (including dark mode) out of
/// the box. Pass a [NepaliCalendarTheme] only to override specific pieces.
@immutable
class NepaliCalendarTheme {
  /// Creates a theme. All arguments are optional overrides.
  const NepaliCalendarTheme({
    this.backgroundColor,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.weekdayLabelColor,
    this.weekendLabelColor,
    this.dayColor,
    this.outsideMonthDayColor,
    this.disabledDayColor,
    this.todayColor,
    this.todayBorderColor,
    this.selectedDayColor,
    this.selectedDayBackgroundColor,
    this.rangeHighlightColor,
    this.markerColor,
    this.holidayColor,
    this.dayTextStyle,
    this.headerTextStyle,
    this.weekdayTextStyle,
    this.cellShape,
  });

  /// Calendar surface background.
  final Color? backgroundColor;

  /// Background of the month/year navigation header.
  final Color? headerBackgroundColor;

  /// Foreground (title + arrows) of the header.
  final Color? headerForegroundColor;

  /// Weekday header label color (Sun-Fri).
  final Color? weekdayLabelColor;

  /// Weekday header label color for Saturday.
  final Color? weekendLabelColor;

  /// Normal in-month day text color.
  final Color? dayColor;

  /// Text color for leading/trailing days from adjacent months.
  final Color? outsideMonthDayColor;

  /// Text color for disabled (unselectable) days.
  final Color? disabledDayColor;

  /// Text color for today's cell when it is not selected.
  final Color? todayColor;

  /// Border drawn around today's cell.
  final Color? todayBorderColor;

  /// Text color inside a selected cell (and range endpoints).
  final Color? selectedDayColor;

  /// Fill behind a selected cell (and range endpoints).
  final Color? selectedDayBackgroundColor;

  /// Fill behind the interior days of a selected range.
  final Color? rangeHighlightColor;

  /// Default dot/badge color for event markers.
  final Color? markerColor;

  /// Emphasis color for holiday days.
  final Color? holidayColor;

  /// Base text style for day numbers.
  final TextStyle? dayTextStyle;

  /// Text style for the header title.
  final TextStyle? headerTextStyle;

  /// Text style for weekday header labels.
  final TextStyle? weekdayTextStyle;

  /// Shape of a day cell's selection/today decoration.
  final ShapeBorder? cellShape;

  /// Returns a fully-populated copy where every null field is filled from
  /// [context]'s theme. Call this once at the top of a build and read the
  /// resolved values below.
  NepaliCalendarTheme resolve(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return NepaliCalendarTheme(
      backgroundColor: backgroundColor ?? scheme.surface,
      headerBackgroundColor: headerBackgroundColor ?? Colors.transparent,
      headerForegroundColor: headerForegroundColor ?? scheme.onSurface,
      weekdayLabelColor: weekdayLabelColor ?? scheme.onSurfaceVariant,
      weekendLabelColor: weekendLabelColor ?? scheme.error,
      dayColor: dayColor ?? scheme.onSurface,
      outsideMonthDayColor: outsideMonthDayColor ??
          scheme.onSurfaceVariant.withValues(alpha: 0.5),
      disabledDayColor:
          disabledDayColor ?? scheme.onSurface.withValues(alpha: 0.38),
      todayColor: todayColor ?? scheme.primary,
      todayBorderColor: todayBorderColor ?? scheme.primary,
      selectedDayColor: selectedDayColor ?? scheme.onPrimary,
      selectedDayBackgroundColor: selectedDayBackgroundColor ?? scheme.primary,
      rangeHighlightColor:
          rangeHighlightColor ?? scheme.primary.withValues(alpha: 0.12),
      markerColor: markerColor ?? scheme.tertiary,
      holidayColor: holidayColor ?? scheme.error,
      dayTextStyle: dayTextStyle ?? textTheme.bodyMedium,
      headerTextStyle: headerTextStyle ?? textTheme.titleMedium,
      weekdayTextStyle: weekdayTextStyle ?? textTheme.labelMedium,
      cellShape: cellShape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
    );
  }

  /// A convenience light theme seeded from [seedColor].
  factory NepaliCalendarTheme.light(
      {Color seedColor = const Color(0xFFDC143C)}) {
    final scheme = ColorScheme.fromSeed(seedColor: seedColor);
    return NepaliCalendarTheme(
      backgroundColor: scheme.surface,
      selectedDayBackgroundColor: scheme.primary,
      selectedDayColor: scheme.onPrimary,
      todayColor: scheme.primary,
    );
  }

  /// A convenience dark theme seeded from [seedColor].
  factory NepaliCalendarTheme.dark(
      {Color seedColor = const Color(0xFFDC143C)}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    return NepaliCalendarTheme(
      backgroundColor: scheme.surface,
      selectedDayBackgroundColor: scheme.primary,
      selectedDayColor: scheme.onPrimary,
      todayColor: scheme.primary,
    );
  }
}
