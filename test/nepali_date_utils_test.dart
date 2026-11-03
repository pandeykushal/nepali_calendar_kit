import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_kit/nepali_calendar_kit.dart';

void main() {
  group('BS to AD conversion anchors', () {
    test('2080-01-01 BS is 2023-04-14 AD', () {
      final ad = const NepaliDate(2080, 1, 1).toDateTime();
      expect(ad.year, 2023);
      expect(ad.month, 4);
      expect(ad.day, 14);
    });

    test('2072-01-12 BS (Gorkha quake) is 2015-04-25 AD', () {
      final ad = const NepaliDate(2072, 1, 12).toDateTime();
      expect(ad.year, 2015);
      expect(ad.month, 4);
      expect(ad.day, 25);
    });
  });

  group('NepaliDateUtils', () {
    test('daysInMonth is queried, in the 29 to 32 range', () {
      for (var m = 1; m <= 12; m++) {
        expect(NepaliDateUtils.daysInMonth(2081, m), inInclusiveRange(29, 32));
      }
    });

    test('isSameDay ignores time', () {
      expect(
        NepaliDateUtils.isSameDay(
          const NepaliDate(2081, 7, 17, 9, 30),
          const NepaliDate(2081, 7, 17, 23, 59),
        ),
        isTrue,
      );
    });

    test('addMonths carries across the year boundary', () {
      final d = NepaliDateUtils.addMonths(const NepaliDate(2081, 12, 10), 1);
      expect(d.year, 2082);
      expect(d.month, 1);
    });

    test('addMonths clamps the day to the target month length', () {
      final moved = NepaliDateUtils.addMonths(const NepaliDate(2081, 1, 31), 1);
      expect(
        moved.day,
        lessThanOrEqualTo(
          NepaliDateUtils.daysInMonth(moved.year, moved.month),
        ),
      );
    });

    test('clamp respects min and max', () {
      const min = NepaliDate(2081, 5, 1);
      const max = NepaliDate(2081, 5, 30);
      expect(
        NepaliDateUtils.clamp(const NepaliDate(2080, 1, 1), min: min, max: max),
        min,
      );
      expect(
        NepaliDateUtils.clamp(const NepaliDate(2099, 1, 1), min: min, max: max),
        max,
      );
    });

    test('isWithin treats null bounds as unbounded', () {
      expect(NepaliDateUtils.isWithin(const NepaliDate(2081, 7, 17)), isTrue);
      expect(
        NepaliDateUtils.isWithin(
          const NepaliDate(2081, 7, 17),
          min: const NepaliDate(2081, 8, 1),
        ),
        isFalse,
      );
    });
  });

  group('NepaliDateRange', () {
    test('orders endpoints regardless of argument order', () {
      final range = NepaliDateRange(
        const NepaliDate(2081, 7, 20),
        const NepaliDate(2081, 7, 10),
      );
      expect(range.start.day, 10);
      expect(range.end.day, 20);
    });

    test('contains and isInterior', () {
      final range = NepaliDateRange(
        const NepaliDate(2081, 7, 10),
        const NepaliDate(2081, 7, 20),
      );
      expect(range.contains(const NepaliDate(2081, 7, 10)), isTrue);
      expect(range.contains(const NepaliDate(2081, 7, 20)), isTrue);
      expect(range.contains(const NepaliDate(2081, 7, 15)), isTrue);
      expect(range.contains(const NepaliDate(2081, 7, 21)), isFalse);
      expect(range.isInterior(const NepaliDate(2081, 7, 10)), isFalse);
      expect(range.isInterior(const NepaliDate(2081, 7, 15)), isTrue);
    });

    test('durationInDays is inclusive', () {
      final range = NepaliDateRange(
        const NepaliDate(2081, 7, 10),
        const NepaliDate(2081, 7, 12),
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
