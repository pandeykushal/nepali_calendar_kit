import '../engine/bs_calendar_data.dart';
import '../engine/nepali_date.dart';

/// Lowest supported BS year in the currently active table.
///
/// Reflects [BsCalendarData.includeExperimental]: 1969 by default, or 1898 when
/// the experimental pre-1969 range is enabled.
int get kNckMinBsYear => BsCalendarData.minYear;

/// Highest supported BS year in the currently active table.
int get kNckMaxBsYear => BsCalendarData.maxYear;

/// Pure (widget-free) date helpers for Bikram Sambat, built on the package's
/// own [NepaliDate] engine. No third-party dependency.
abstract final class NepaliDateUtils {
  /// Number of days in the BS [month] of [year] (varies 29-32).
  static int daysInMonth(int year, int month) =>
      BsCalendarData.daysInMonth(year, month);

  /// Weekday of the first day of the BS [month] (Sunday = 1 ... Saturday = 7).
  ///
  /// The zero-based grid column for day 1 is `firstWeekday(year, month) - 1`.
  static int firstWeekday(int year, int month) =>
      NepaliDate(year, month).weekday;

  /// `true` if [a] and [b] fall on the same calendar day (time ignored).
  static bool isSameDay(NepaliDate a, NepaliDate b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Today's BS date with the time stripped to midnight.
  static NepaliDate today() {
    final now = NepaliDate.now();
    return NepaliDate(now.year, now.month, now.day);
  }

  /// Returns [date] with its time component removed (set to midnight).
  static NepaliDate dateOnly(NepaliDate date) =>
      NepaliDate(date.year, date.month, date.day);

  /// Adds [delta] whole months to [date], carrying across year boundaries and
  /// clamping the day to the target month length and year to the supported
  /// range.
  static NepaliDate addMonths(NepaliDate date, int delta) {
    var year = date.year;
    var monthIndex = (date.month - 1) + delta;
    year += monthIndex ~/ 12;
    monthIndex %= 12;
    if (monthIndex < 0) {
      monthIndex += 12;
      year -= 1;
    }
    year = year.clamp(kNckMinBsYear, kNckMaxBsYear);
    final month = monthIndex + 1;
    final lastDay = daysInMonth(year, month);
    final day = date.day > lastDay ? lastDay : date.day;
    return NepaliDate(year, month, day);
  }

  /// Adds [delta] years to [date], clamping the day and year.
  static NepaliDate addYears(NepaliDate date, int delta) {
    final year = (date.year + delta).clamp(kNckMinBsYear, kNckMaxBsYear);
    final lastDay = daysInMonth(year, date.month);
    final day = date.day > lastDay ? lastDay : date.day;
    return NepaliDate(year, date.month, day);
  }

  /// Clamps [date] into the inclusive `[min, max]` window (null = unbounded).
  static NepaliDate clamp(
    NepaliDate date, {
    NepaliDate? min,
    NepaliDate? max,
  }) {
    var result = date;
    if (min != null && result.isBefore(min)) result = min;
    if (max != null && result.isAfter(max)) result = max;
    return result;
  }

  /// `true` if [date] is within the inclusive `[min, max]` window (by day).
  static bool isWithin(
    NepaliDate date, {
    NepaliDate? min,
    NepaliDate? max,
  }) {
    final d = dateOnly(date);
    if (min != null && d.isBefore(dateOnly(min))) return false;
    if (max != null && d.isAfter(dateOnly(max))) return false;
    return true;
  }

  /// Saturday is the weekend in Nepal. Returns `true` for Saturdays.
  static bool isWeekend(NepaliDate date) => date.weekday == 7;

  /// A stable `yyyy-mm-dd` key for indexing maps of events/markers by day.
  static String dayKey(NepaliDate date) =>
      '${date.year}-${date.month}-${date.day}';
}
