import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_kit/nepali_calendar_kit.dart';

void main() {
  group('NepaliMonthGrid', () {
    test('always produces a 6×7 (42-cell) grid', () {
      for (var m = 1; m <= 12; m++) {
        final grid = NepaliMonthGrid(2081, m);
        expect(grid.days.length, 42, reason: 'month $m');
        expect(grid.rowCount, 6);
        expect(grid.columnCount, 7);
      }
    });

    test('leading blanks match the first weekday (Sun=1..Sat=7)', () {
      final grid = NepaliMonthGrid(2081, 7);
      final firstWeekday = NepaliDateUtils.firstWeekday(2081, 7);
      expect(grid.leadingBlankCount, firstWeekday - 1);

      final firstInMonthIndex =
          grid.days.indexWhere((d) => d.inMonth && d.date.day == 1);
      expect(firstInMonthIndex, grid.leadingBlankCount);
    });

    test('in-month cells are contiguous and cover every day', () {
      final grid = NepaliMonthGrid(2081, 2);
      final inMonth = grid.days.where((d) => d.inMonth).toList();
      expect(inMonth.length, grid.daysInMonth);
      for (var i = 0; i < inMonth.length; i++) {
        expect(inMonth[i].date.day, i + 1);
        expect(inMonth[i].date.month, 2);
        expect(inMonth[i].date.year, 2081);
      }
    });

    test('leading filler days come from the previous month', () {
      final grid = NepaliMonthGrid(2081, 7);
      if (grid.leadingBlankCount > 0) {
        final firstCell = grid.days.first;
        expect(firstCell.inMonth, isFalse);
        expect(firstCell.date.month, 6);
      }
    });

    test('row() returns 7 cells per week', () {
      final grid = NepaliMonthGrid(2080, 1);
      for (var w = 0; w < 6; w++) {
        expect(grid.row(w).length, 7);
      }
    });
  });
}
