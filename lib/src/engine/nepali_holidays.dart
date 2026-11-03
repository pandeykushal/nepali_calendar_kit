import 'nepali_date.dart';
import '../models/calendar_event.dart';

/// A holiday definition. Either [fixed] (same BS month/day every year, e.g.
/// some national days) or a one-off on a specific [date] (for lunar/tithi
/// festivals whose BS date differs each year).
class NepaliHoliday {
  /// A holiday that repeats on the same BS month/day every year.
  const NepaliHoliday.fixed({
    required this.title,
    required int month,
    required int day,
    this.isPublic = true,
  })  : _month = month,
        _day = day,
        date = null;

  /// A holiday on one specific BS date (for movable/tithi festivals).
  const NepaliHoliday.on(this.date, {required this.title, this.isPublic = true})
      : _month = null,
        _day = null;

  /// Holiday name.
  final String title;

  /// Whether it is a public (non-working) holiday.
  final bool isPublic;

  /// The fixed date, for [NepaliHoliday.on]; otherwise null.
  final NepaliDate? date;

  final int? _month;
  final int? _day;

  /// Whether this holiday falls on [d].
  bool matches(NepaliDate d) {
    if (date != null) {
      return d.year == date!.year && d.month == date!.month && d.day == date!.day;
    }
    return d.month == _month && d.day == _day;
  }
}

/// Builds a calendar `events` map from a list of [NepaliHoliday] definitions.
///
/// IMPORTANT: this ships the *mechanism*, not a complete dataset. Most Nepali
/// festivals (Dashain, Tihar, Teej, ...) are lunar/tithi-based and change BS date
/// each year, so a correct dataset must be supplied/maintained by you. The
/// [sample] below is a tiny, illustrative placeholder - replace it.
abstract final class NepaliHolidays {
  /// Expands [holidays] into an events map for the BS years in
  /// `[fromYear, toYear]`, ready to pass to `NepaliCalendar(events: ...)`.
  static Map<NepaliDate, List<CalendarEvent>> toEvents(
    List<NepaliHoliday> holidays, {
    required int fromYear,
    required int toYear,
  }) {
    final map = <NepaliDate, List<CalendarEvent>>{};
    void add(NepaliDate d, NepaliHoliday h) {
      (map[d] ??= <CalendarEvent>[]).add(
        CalendarEvent(title: h.title, isHoliday: true),
      );
    }

    for (final h in holidays) {
      if (h.date != null) {
        add(h.date!, h);
      } else {
        for (var y = fromYear; y <= toYear; y++) {
          add(NepaliDate(y, h._month!, h._day!), h);
        }
      }
    }
    return map;
  }

  /// A tiny ILLUSTRATIVE sample (not a complete or authoritative list).
  /// Replace with your maintained dataset.
  static const List<NepaliHoliday> sample = <NepaliHoliday>[
    NepaliHoliday.fixed(title: 'New Year (Baisakh 1)', month: 1, day: 1),
    NepaliHoliday.fixed(title: 'Labour Day (sample)', month: 1, day: 18),
  ];
}
