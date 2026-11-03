import 'dart:ui' show Color;

/// A marker shown on a day cell - a holiday, tithi, reminder, or any dot/badge
/// the host app wants to surface.
///
/// The package ships **no** holiday data on purpose (holiday/tithi data changes
/// yearly and is maintenance-heavy). Instead, hosts supply a
/// `Map<NepaliDate, List<CalendarEvent>>` and the calendar renders it. A
/// bundled dataset may arrive in a later version.
class CalendarEvent {
  /// Creates an event/marker.
  const CalendarEvent({
    required this.title,
    this.color,
    this.isHoliday = false,
    this.metadata,
  });

  /// Human-readable label, e.g. `'Dashain'` or `'Ekadashi'`.
  final String title;

  /// Optional dot/badge color. When null the calendar theme's marker color is
  /// used.
  final Color? color;

  /// When `true`, the day may be rendered with the holiday emphasis (and can be
  /// auto-highlighted like a weekend if the host opts in).
  final bool isHoliday;

  /// Arbitrary caller payload (an id, a route, a model object...). The package
  /// never inspects this; it is passed straight back in builder callbacks.
  final Object? metadata;
}
