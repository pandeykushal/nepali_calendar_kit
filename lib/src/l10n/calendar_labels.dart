import '../engine/language.dart';
import '../engine/nepali_date_names.dart';

/// Thin, stable facade over [NepaliDateNames] for the widget layer.
///
/// Kept as its own name so widget code reads clearly; all data lives in
/// [NepaliDateNames] so there is a single source of truth.
abstract final class NepaliCalendarLabels {
  /// English short weekday headers, Sunday → Saturday.
  static const List<String> weekdayHeadersEn = NepaliDateNames.weekdaysShortEn;

  /// Nepali short weekday headers, Sunday → Saturday.
  static const List<String> weekdayHeadersNp = NepaliDateNames.weekdaysShortNp;

  /// English full month names, Baisakh (0) → Chaitra (11).
  static const List<String> monthNamesEn = NepaliDateNames.monthsEn;

  /// Nepali full month names, Baisakh (0) → Chaitra (11).
  static const List<String> monthNamesNp = NepaliDateNames.monthsNp;

  /// Weekday header list (index 0 = Sunday) for [language].
  static List<String> weekdayHeaders(Language language) =>
      NepaliDateNames.weekdayHeaders(language);

  /// Month name for 1-based [month] in [language].
  static String monthName(int month, Language language) =>
      NepaliDateNames.month(month, language);

  /// Renders an integer in [language]'s digits, no grouping separators.
  static String digits(int value, Language language) =>
      NepaliDateNames.digits(value, language);
}
