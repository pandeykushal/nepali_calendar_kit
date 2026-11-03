import 'bs_calendar_data.dart';

/// A Bikram Sambat date(-time), independent of any third-party package.
///
/// Conversion to/from AD (Gregorian) is pure day-counting over
/// [BsCalendarData]'s month-length table from a single verified anchor, so the
/// supported range is exactly the range your table covers.
///
/// Weekday convention matches Nepali calendars: Sunday = 1 ... Saturday = 7.
class NepaliDate implements Comparable<NepaliDate> {
  /// Creates a BS date. [month] (1-12) defaults to 1 and [day] to 1, so
  /// `NepaliDate(2081)` is Baisakh 1, 2081. Time parts default to midnight.
  ///
  /// Does not itself validate the day against the month length (so you can
  /// construct the first day of a month cheaply); use [isValid] to check.
  const NepaliDate(
    this.year, [
    this.month = 1,
    this.day = 1,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
  ]);

  /// BS year.
  final int year;

  /// BS month, 1 (Baisakh) - 12 (Chaitra).
  final int month;

  /// BS day of month.
  final int day;

  /// Hour, 0-23.
  final int hour;

  /// Minute, 0-59.
  final int minute;

  /// Second, 0-59.
  final int second;

  /// The AD anchor as a [DateTime] (midnight).
  static final DateTime _anchorAd =
      DateTime(kAnchorAdYear, kAnchorAdMonth, kAnchorAdDay);

  /// Epoch-day index of the anchor, recomputed each call so it always uses the
  /// same `minYear` basis as the date being converted. (Computing it once would
  /// go stale if [BsCalendarData.includeExperimental] is toggled, since that
  /// shifts `minYear`.)
  static int _anchorEpochDays() =>
      _epochDays(kAnchorBsYear, kAnchorBsMonth, kAnchorBsDay);

  /// Current BS date-time, derived from the device clock.
  factory NepaliDate.now() => NepaliDate.fromDateTime(DateTime.now());

  /// Converts an AD [dateTime] to its BS date-time.
  factory NepaliDate.fromDateTime(DateTime dateTime) {
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = dateOnly.difference(_anchorAd).inDays;
    var remaining = _anchorEpochDays() + diff;

    if (remaining < 0) {
      throw ArgumentError(
        'Date ${dateTime.toIso8601String()} is before the supported BS range '
        '(${BsCalendarData.minYear}).',
      );
    }

    var year = BsCalendarData.minYear;
    while (true) {
      if (!BsCalendarData.hasYear(year)) {
        throw ArgumentError(
          'Date ${dateTime.toIso8601String()} is after the supported BS range '
          '(${BsCalendarData.maxYear}).',
        );
      }
      final inYear = BsCalendarData.daysInYear(year);
      if (remaining < inYear) break;
      remaining -= inYear;
      year++;
    }

    var month = 1;
    while (remaining >= BsCalendarData.daysInMonth(year, month)) {
      remaining -= BsCalendarData.daysInMonth(year, month);
      month++;
    }

    return NepaliDate(
      year,
      month,
      remaining + 1,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }

  /// Parses an ISO-like BS string: `yyyy-MM-dd` or
  /// `yyyy-MM-ddTHH:mm:ss` (separators `-`/`/`/`.` accepted, time optional).
  /// Accepts Devanagari **or** ASCII digits. Throws [FormatException] on bad
  /// input or an impossible date.
  static NepaliDate parse(String input) {
    final parsed = tryParse(input);
    if (parsed == null) {
      throw FormatException('Not a valid BS date', input);
    }
    return parsed;
  }

  /// Like [parse] but returns null instead of throwing.
  static NepaliDate? tryParse(String input) {
    final ascii = _toAsciiDigits(input.trim());
    final m = RegExp(
      r'^(\d{1,4})[-/.](\d{1,2})[-/.](\d{1,2})'
      r'(?:[T ](\d{1,2}):(\d{1,2})(?::(\d{1,2}))?)?$',
    ).firstMatch(ascii);
    if (m == null) return null;
    final year = int.parse(m.group(1)!);
    final month = int.parse(m.group(2)!);
    final day = int.parse(m.group(3)!);
    final hour = m.group(4) == null ? 0 : int.parse(m.group(4)!);
    final minute = m.group(5) == null ? 0 : int.parse(m.group(5)!);
    final second = m.group(6) == null ? 0 : int.parse(m.group(6)!);
    final date = NepaliDate(year, month, day, hour, minute, second);
    if (!date.isValid || hour > 23 || minute > 59 || second > 59) return null;
    return date;
  }

  /// Converts any Devanagari digits in [s] to ASCII `0-9`.
  static String _toAsciiDigits(String s) {
    final buffer = StringBuffer();
    for (final rune in s.runes) {
      if (rune >= 0x0966 && rune <= 0x096F) {
        buffer.writeCharCode(0x30 + (rune - 0x0966));
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// Days since the table's first day (minYear/1/1) for a BS date.
  static int _epochDays(int year, int month, int day) {
    var days = 0;
    for (var y = BsCalendarData.minYear; y < year; y++) {
      days += BsCalendarData.daysInYear(y);
    }
    for (var m = 1; m < month; m++) {
      days += BsCalendarData.daysInMonth(year, m);
    }
    return days + (day - 1);
  }

  /// Converts this BS date to its AD [DateTime] (carrying the time parts).
  DateTime toDateTime() {
    final dayDelta = _epochDays(year, month, day) - _anchorEpochDays();
    final adDate = _anchorAd.add(Duration(days: dayDelta));
    return DateTime(adDate.year, adDate.month, adDate.day, hour, minute, second);
  }

  /// Day of week, Sunday = 1 ... Saturday = 7.
  int get weekday => toDateTime().weekday % 7 + 1;

  /// Days in this date's month.
  int get daysInMonth => BsCalendarData.daysInMonth(year, month);

  /// `true` if the day falls within this month's real length.
  bool get isValid =>
      BsCalendarData.hasYear(year) &&
      month >= 1 &&
      month <= 12 &&
      day >= 1 &&
      day <= daysInMonth;

  /// This date with the time stripped to midnight.
  NepaliDate get dateOnly => NepaliDate(year, month, day);

  /// Returns a new date [duration] later (via AD arithmetic).
  NepaliDate add(Duration duration) =>
      NepaliDate.fromDateTime(toDateTime().add(duration));

  /// Returns a new date [duration] earlier.
  NepaliDate subtract(Duration duration) =>
      NepaliDate.fromDateTime(toDateTime().subtract(duration));

  /// Difference between this date and [other].
  Duration difference(NepaliDate other) =>
      toDateTime().difference(other.toDateTime());

  /// `true` if this is strictly before [other] (compared by day).
  bool isBefore(NepaliDate other) => compareTo(other) < 0;

  /// `true` if this is strictly after [other] (compared by day).
  bool isAfter(NepaliDate other) => compareTo(other) > 0;

  @override
  int compareTo(NepaliDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is NepaliDate &&
      other.year == year &&
      other.month == month &&
      other.day == day &&
      other.hour == hour &&
      other.minute == minute &&
      other.second == second;

  @override
  int get hashCode => Object.hash(year, month, day, hour, minute, second);

  @override
  String toString() =>
      '$year-${_two(month)}-${_two(day)} ${_two(hour)}:${_two(minute)}:${_two(second)}';

  static String _two(int n) => n.toString().padLeft(2, '0');
}

/// AD → BS convenience, mirroring `DateTime.toNepaliDate()`.
extension NepaliDateFromDateTime on DateTime {
  /// Converts this AD date to a [NepaliDate].
  NepaliDate toNepaliDate() => NepaliDate.fromDateTime(this);
}
