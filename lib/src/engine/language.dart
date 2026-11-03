/// Language for digits, month names and weekday names.
///
/// This is `nepali_calendar_kit`'s own enum - the package no longer depends on
/// `nepali_utils`, so this type is independent of it.
enum Language {
  /// English (Latin digits, English month/weekday names).
  english,

  /// Nepali (Devanagari digits, Nepali month/weekday names).
  nepali,
}
