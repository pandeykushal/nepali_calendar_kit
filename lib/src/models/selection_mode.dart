/// How the calendar responds to taps on day cells.
enum NepaliSelectionMode {
  /// No selection; the calendar is display-only (useful for an event viewer).
  none,

  /// A single day is selectable at a time.
  single,

  /// A contiguous start→end range is selectable. The first tap sets the start,
  /// the second sets the end; a third tap starts a new range.
  range,

  /// Several non-contiguous days are selectable; tapping toggles a day.
  multiple,
}
