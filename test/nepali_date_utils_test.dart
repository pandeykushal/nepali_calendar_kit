import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_kit/nepali_calendar_kit.dart';

void main() {
  group('BS↔AD conversion anchors (built-in engine)', () {
    test('2080-01-01 BS == 2023-04-14 AD', () {
      final ad = NepaliDate(2080, 1, 1).toDateTime();
      expect(ad.year, 2023);
      expect(ad.month, 4);
      expect(ad.day, 14);
    });

    test('2072-01-12 BS (Gorkha quake) == 2015-04-25 AD', () {
      final ad = NepaliDate(2072, 1, 12).toDateTime();
      expect(ad.year, 2015);
      expect(ad.month, 4);
      expect(ad.day, 25);
    });
  });

  group('NepaliDateUtils', () {
    test('daysInMonth is queried, never assumed (29-32 range)', () {
      for (var m = 1; m <= 12; m++) {
        final days = NepaliDateUtils.daysInMonth(2081, m);
        expect(days, inInclusiveRange(29, 32), reason: 'month $m');
      }
    });

    test('isSameDay ignores time', () {
      final a = NepaliDate(2081, 7, 17, 9, 30);
      final b = NepaliDate(2081, 7, 17, 23, 59);
      expect(NepaliDateUtils.isSameDay(a, b), isTrue);
    });

    test('addMonths carries across the year boundary', () {
      final d = NepaliDateUtils.addMonths(NepaliDate(2081, 12, 10), 1);
      expect(d.year, 2082);
      expect(d.month, 1);
    });

    test('addMonths clamps the day to the target month length', () {
      final start = NepaliDate(2081, 1, 31);
      final moved = NepaliDateUtils.addMonths(start, 1);
      expect(moved.day, lessThanOrEqualTo(NepaliDateUtils.daysInMonth(moved.year, moved.month)));
    });

    test('clamp respects min and max', () {
      final min = NepaliDate(2081, 5, 1);
      final max = NepaliDate(2081, 5, 30);
      expect(
        NepaliDateUtils.clamp(NepaliDate(2080, 1, 1), min: min, max: max),
        min,
      );
      expect(
        NepaliDateUtils.clamp(NepaliDate(2099, 1, 1), min: min, max: max),
        max,
      );
    });

    test('isWithin treats null bounds as unbounded', () {
      expect(
        NepaliDateUtils.isWithin(NepaliDate(2081, 7, 17)),
        isTrue,
      );
      expect(
        NepaliDateUtils.isWithin(
          NepaliDate(2081, 7, 17),
          min: NepaliDate(2081, 8, 1),
        ),
        isFalse,
      );
    });

    test('Saturday is the weekend', () {
      var d = NepaliDate(2081, 7, 1);
      var found = false;
      for (var i = 0; i < 7; i++) {
        final day = d.add(Duration(days: i));
        if (day.weekday == 7) {
          expect(NepaliDateUtils.isWeekend(day), isTrue);
          found = true;
        } else {
          expect(NepaliDateUtils.isWeekend(day), isFalse);
        }
      }
      expect(found, isTrue);
    });
  });

  group('NepaliDateRange', () {
    test('orders endpoints regardless of argument order', () {
      final a = NepaliDate(2081, 7, 20);
      final b = NepaliDate(2081, 7, 10);
      final range = NepaliDateRange(a, b);
      expect(range.start.day, 10);
      expect(range.end.day, 20);
    });

    test('contains and isInterior', () {
      final range = NepaliDateRange(
        NepaliDate(2081, 7, 10),
        NepaliDate(2081, 7, 20),
      );
      expect(range.contains(NepaliDate(2081, 7, 10)), isTrue);
      expect(range.contains(NepaliDate(2081, 7, 20)), isTrue);
      expect(range.contains(NepaliDate(2081, 7, 15)), isTrue);
      expect(range.contains(NepaliDate(2081, 7, 21)), isFalse);
      expect(range.isInterior(NepaliDate(2081, 7, 10)), isFalse);
      expect(range.isInterior(NepaliDate(2081, 7, 15)), isTrue);
    });

    test('durationInDays is inclusive', () {
      final range = NepaliDateRange(
        NepaliDate(2081, 7, 10),
        NepaliDate(2081, 7, 12),
      );
      expect(range.durationInDays, 3);
    });
  });

  group('NepaliCalendarLabels', () {
    test('Nepali digits have no grouping separators', () {
      expect(NepaliCalendarLabels.digits(2081, Language.nepali), '२०८१');
      expect(NepaliCalendarLabels.digits(17, Language.nepali), '१७');
    });

    test('English digits pass through', () {
      expect(NepaliCalendarLabels.digits(2081, Language.english), '2081');
    });

    test('month names have 12 entries in both languages', () {
      expect(NepaliCalendarLabels.monthNamesEn.length, 12);
      expect(NepaliCalendarLabels.monthNamesNp.length, 12);
    });
  });
}
