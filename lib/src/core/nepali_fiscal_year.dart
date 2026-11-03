import '../engine/bs_calendar_data.dart';
import '../engine/nepali_date.dart';
import 'date_range.dart';

/// Nepali fiscal year, which runs **Shrawan 1 → Ashadh end** (month 4 of one
/// BS year to month 3 of the next), and its four quarters.
///
/// Quarters: Q1 Shrawan-Ashwin (4-6), Q2 Kartik-Poush (7-9),
/// Q3 Magh-Chaitra (10-12), Q4 Baisakh-Ashadh (1-3).
class NepaliFiscalYear {
  NepaliFiscalYear._(this.startYear);

  /// The BS year in which this fiscal year begins (its Shrawan).
  final int startYear;

  /// The fiscal year containing [date].
  factory NepaliFiscalYear.of(NepaliDate date) =>
      NepaliFiscalYear._(date.month >= 4 ? date.year : date.year - 1);

  /// First day of the fiscal year (Shrawan 1 of [startYear]).
  NepaliDate get start => NepaliDate(startYear, 4, 1);

  /// Last day of the fiscal year (Ashadh end of the next BS year).
  NepaliDate get end => NepaliDate(
        startYear + 1,
        3,
        BsCalendarData.daysInMonth(startYear + 1, 3),
      );

  /// The whole fiscal year as a range.
  NepaliDateRange get range => NepaliDateRange(start, end);

  /// Label like `2081/82`.
  String get label =>
      '$startYear/${((startYear + 1) % 100).toString().padLeft(2, '0')}';

  /// Quarter number (1-4) that [date] falls in within a fiscal year.
  static int quarterOf(NepaliDate date) {
    switch (date.month) {
      case 4:
      case 5:
      case 6:
        return 1;
      case 7:
      case 8:
      case 9:
        return 2;
      case 10:
      case 11:
      case 12:
        return 3;
      default:
        return 4;
    }
  }

  /// Range of quarter [q] (1-4) within this fiscal year.
  NepaliDateRange quarter(int q) {
    assert(q >= 1 && q <= 4, 'Quarter must be 1-4');
    switch (q) {
      case 1:
        return NepaliDateRange(
          NepaliDate(startYear, 4, 1),
          NepaliDate(startYear, 6, BsCalendarData.daysInMonth(startYear, 6)),
        );
      case 2:
        return NepaliDateRange(
          NepaliDate(startYear, 7, 1),
          NepaliDate(startYear, 9, BsCalendarData.daysInMonth(startYear, 9)),
        );
      case 3:
        return NepaliDateRange(
          NepaliDate(startYear, 10, 1),
          NepaliDate(startYear, 12, BsCalendarData.daysInMonth(startYear, 12)),
        );
      default:
        return NepaliDateRange(
          NepaliDate(startYear + 1, 1, 1),
          NepaliDate(
              startYear + 1, 3, BsCalendarData.daysInMonth(startYear + 1, 3)),
        );
    }
  }
}
