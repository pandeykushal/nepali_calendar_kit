import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_kit/nepali_calendar_kit.dart';

void main() {
  group('Parsing', () {
    test('NepaliDate.parse ISO forms', () {
      final a = NepaliDate.parse('2081-07-03');
      expect([a.year, a.month, a.day], [2081, 7, 3]);
      final b = NepaliDate.parse('2081/7/3');
      expect([b.year, b.month, b.day], [2081, 7, 3]);
      final c = NepaliDate.parse('2081-07-03T09:05:30');
      expect([c.hour, c.minute, c.second], [9, 5, 30]);
    });

    test('NepaliDate.parse accepts Devanagari digits', () {
      final d = NepaliDate.parse('२०८१-०७-०३');
      expect([d.year, d.month, d.day], [2081, 7, 3]);
    });

    test('tryParse rejects impossible dates', () {
      expect(NepaliDate.tryParse('2081-13-01'), isNull);
      expect(NepaliDate.tryParse('nope'), isNull);
    });

    test('NepaliDateFormat round-trips format then parse', () {
      const fmt = NepaliDateFormat('EEE, MMMM d, y');
      final s = fmt.format(const NepaliDate(2081, 7, 3));
      final back = fmt.parse(s);
      expect([back.year, back.month, back.day], [2081, 7, 3]);
    });
  });

  group('Age', () {
    test('exact years', () {
      final age = NepaliAge.between(
        const NepaliDate(2050, 1, 15),
        const NepaliDate(2080, 1, 15),
      );
      expect([age.years, age.months, age.days], [30, 0, 0]);
    });

    test('fields stay in range', () {
      final age = NepaliAge.between(
        const NepaliDate(2050, 1, 20),
        const NepaliDate(2080, 1, 15),
      );
      expect(age.months, inInclusiveRange(0, 11));
      expect(age.days, inInclusiveRange(0, 32));
    });
  });

  group('Relative time', () {
    const ref = NepaliDate(2081, 7, 10);

    test('english', () {
      expect(
        NepaliRelativeTime.format(const NepaliDate(2081, 7, 10), reference: ref),
        'today',
      );
      expect(
        NepaliRelativeTime.format(const NepaliDate(2081, 7, 9), reference: ref),
        'yesterday',
      );
      expect(
        NepaliRelativeTime.format(const NepaliDate(2081, 7, 11), reference: ref),
        'tomorrow',
      );
    });

    test('nepali', () {
      expect(
        NepaliRelativeTime.format(
          const NepaliDate(2081, 7, 10),
          reference: ref,
          language: Language.nepali,
        ),
        'आज',
      );
    });
  });

  group('Fiscal year', () {
    test('Shrawan starts the FY', () {
      final fy = NepaliFiscalYear.of(const NepaliDate(2081, 5, 10));
      expect(fy.startYear, 2081);
      expect(fy.label, '2081/82');
      expect([fy.start.month, fy.start.day], [4, 1]);
      expect(fy.end.month, 3);
    });

    test('Baisakh belongs to the previous FY', () {
      final fy = NepaliFiscalYear.of(const NepaliDate(2081, 2, 10));
      expect(fy.startYear, 2080);
    });

    test('quarter mapping', () {
      expect(NepaliFiscalYear.quarterOf(const NepaliDate(2081, 4, 1)), 1);
      expect(NepaliFiscalYear.quarterOf(const NepaliDate(2081, 7, 1)), 2);
      expect(NepaliFiscalYear.quarterOf(const NepaliDate(2081, 10, 1)), 3);
      expect(NepaliFiscalYear.quarterOf(const NepaliDate(2081, 1, 1)), 4);
    });
  });

  group('Presets', () {
    test('today and this week', () {
      final p = NepaliDatePresets(asOf: const NepaliDate(2081, 7, 10));
      expect(p.today.durationInDays, 1);
      expect(p.thisWeek.durationInDays, 7);
    });
  });

  group('Holidays', () {
    test('fixed holiday expands across years', () {
      final events = NepaliHolidays.toEvents(
        const [NepaliHoliday.fixed(title: 'New Year', month: 1, day: 1)],
        fromYear: 2080,
        toYear: 2082,
      );
      expect(events.keys.where((d) => d.month == 1 && d.day == 1).length, 3);
    });

    test('researched candidate dataset has only valid dates', () {
      for (final year in [2081, 2082]) {
        for (final h in candidateHolidaysForYear(year)) {
          expect(h.date!.isValid, isTrue);
        }
      }
    });
  });
}
