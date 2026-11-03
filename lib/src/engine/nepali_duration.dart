import 'bs_calendar_data.dart';
import 'nepali_date.dart';

/// A calendar difference broken into whole years, months and days - what a
/// date-of-birth form means by "age".
class NepaliDateDuration {
  /// Creates a broken-down duration.
  const NepaliDateDuration({
    required this.years,
    required this.months,
    required this.days,
  });

  /// Whole years.
  final int years;

  /// Whole months after the years.
  final int months;

  /// Whole days after the months.
  final int days;

  /// English summary, e.g. `25 years, 3 months, 12 days`.
  @override
  String toString() => '$years years, $months months, $days days';
}

/// Age / duration helpers over BS dates.
abstract final class NepaliAge {
  /// Years-months-days from [birth] up to [asOf] (defaults to today).
  ///
  /// Uses real BS month lengths when borrowing days, so the result matches how
  /// ages are counted on Nepali forms. If [asOf] is before [birth] the fields
  /// are returned as a positive magnitude.
  static NepaliDateDuration between(NepaliDate birth, [NepaliDate? asOf]) {
    var a = birth.dateOnly;
    var b = (asOf ?? NepaliDate.now()).dateOnly;
    if (a.isAfter(b)) {
      final tmp = a;
      a = b;
      b = tmp;
    }

    var years = b.year - a.year;
    var months = b.month - a.month;
    var days = b.day - a.day;

    if (days < 0) {
      months -= 1;
      var pm = b.month - 1;
      var py = b.year;
      if (pm < 1) {
        pm = 12;
        py -= 1;
      }
      days += BsCalendarData.daysInMonth(py, pm);
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    return NepaliDateDuration(years: years, months: months, days: days);
  }

  /// Total whole days between [a] and [b] (absolute value).
  static int totalDays(NepaliDate a, NepaliDate b) =>
      a.difference(b).inDays.abs();
}
