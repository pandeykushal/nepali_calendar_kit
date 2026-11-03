import '../engine/nepali_date.dart';
import 'nepali_date_utils.dart';

/// One cell of a month grid.
///
/// A cell either belongs to the displayed month ([inMonth] is `true`) or is a
/// leading/trailing filler padding the 6×7 grid. Filler cells still carry a
/// real [date] (the adjacent month's day).
class NepaliGridDay {
  /// Creates a grid cell.
  const NepaliGridDay({required this.date, required this.inMonth});

  /// The BS date this cell represents.
  final NepaliDate date;

  /// Whether [date] is within the month the grid was built for.
  final bool inMonth;
}

/// Headless model of a single BS month as a fixed 6-row × 7-column grid (42
/// cells), week starting Sunday.
///
/// Pure data, no Flutter dependency. Days-in-month and the first weekday come
/// from the package's own engine. Height is always 6 rows so the calendar does
/// not jump between 5 and 6 rows when paging.
class NepaliMonthGrid {
  NepaliMonthGrid._({
    required this.year,
    required this.month,
    required this.days,
    required this.daysInMonth,
    required this.leadingBlankCount,
  });

  /// Builds the grid for 1-based [month] of BS [year].
  factory NepaliMonthGrid(int year, int month) {
    final daysInMonth = NepaliDateUtils.daysInMonth(year, month);
    final leading = NepaliDateUtils.firstWeekday(year, month) - 1;

    final cells = <NepaliGridDay>[];

    if (leading > 0) {
      final prev = NepaliDateUtils.addMonths(NepaliDate(year, month), -1);
      final prevDays = NepaliDateUtils.daysInMonth(prev.year, prev.month);
      for (var i = leading; i > 0; i--) {
        cells.add(
          NepaliGridDay(
            date: NepaliDate(prev.year, prev.month, prevDays - i + 1),
            inMonth: false,
          ),
        );
      }
    }

    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(
        NepaliGridDay(date: NepaliDate(year, month, d), inMonth: true),
      );
    }

    final next = NepaliDateUtils.addMonths(NepaliDate(year, month), 1);
    var nextDay = 1;
    while (cells.length < 42) {
      cells.add(
        NepaliGridDay(
          date: NepaliDate(next.year, next.month, nextDay),
          inMonth: false,
        ),
      );
      nextDay++;
    }

    return NepaliMonthGrid._(
      year: year,
      month: month,
      days: List<NepaliGridDay>.unmodifiable(cells),
      daysInMonth: daysInMonth,
      leadingBlankCount: leading,
    );
  }

  /// The BS year this grid represents.
  final int year;

  /// The 1-based BS month this grid represents.
  final int month;

  /// All 42 cells in row-major order (row 0 = first week).
  final List<NepaliGridDay> days;

  /// Number of days in [month] of [year].
  final int daysInMonth;

  /// Number of leading filler cells before day 1 (0-6).
  final int leadingBlankCount;

  /// Always 6 - the fixed number of rows.
  int get rowCount => 6;

  /// Always 7 - one column per weekday.
  int get columnCount => 7;

  /// The [week]-th row (0-5) as a 7-item list.
  List<NepaliGridDay> row(int week) => days.sublist(week * 7, week * 7 + 7);
}
