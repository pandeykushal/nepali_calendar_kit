import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_calendar_kit/src/engine/bs_calendar_data.dart';
import 'package:nepali_calendar_kit/src/engine/nepali_date.dart';

void main() {
  tearDown(() => BsCalendarData.includeExperimental = false);

  group('Verified tier (default)', () {
    test('range is 1969-2250', () {
      expect(BsCalendarData.minYear, 1969);
      expect(BsCalendarData.maxYear, 2250);
    });

    test('table is structurally sound', () {
      expect(BsCalendarData.validate(), isEmpty);
    });

    test('every date round-trips BS→AD→BS', () {
      for (var y = BsCalendarData.minYear; y <= BsCalendarData.maxYear; y++) {
        for (var m = 1; m <= 12; m++) {
          final dim = BsCalendarData.daysInMonth(y, m);
          for (var d = 1; d <= dim; d++) {
            final back =
                NepaliDate.fromDateTime(NepaliDate(y, m, d).toDateTime());
            expect([back.year, back.month, back.day], [y, m, d]);
          }
        }
      }
    });

    test('known real anchors', () {
      final a = const NepaliDate(2080, 1, 1).toDateTime();
      expect([a.year, a.month, a.day], [2023, 4, 14]);
      final quake = const NepaliDate(2072, 1, 12).toDateTime();
      expect([quake.year, quake.month, quake.day], [2015, 4, 25]);
      final anchor = const NepaliDate(1970, 1, 1).toDateTime();
      expect([anchor.year, anchor.month, anchor.day], [1913, 4, 13]);
    });

    test('pre-1969 throws while experimental is off', () {
      expect(
          () => const NepaliDate(1950, 1, 1).toDateTime(), throwsArgumentError);
    });
  });

  group('Experimental tier (opt-in)', () {
    setUp(() => BsCalendarData.includeExperimental = true);

    test('enabling extends the floor to 1898', () {
      expect(BsCalendarData.minYear, 1898);
    });

    test('modern anchors stay correct with experimental on', () {
      final a = const NepaliDate(2080, 1, 1).toDateTime();
      expect([a.year, a.month, a.day], [2023, 4, 14]);
    });

    test('pre-1969 dates round-trip (internally consistent)', () {
      for (var y = 1898; y <= 1968; y++) {
        for (var m = 1; m <= 12; m++) {
          final dim = BsCalendarData.daysInMonth(y, m);
          for (var d = 1; d <= dim; d++) {
            final back =
                NepaliDate.fromDateTime(NepaliDate(y, m, d).toDateTime());
            expect([back.year, back.month, back.day], [y, m, d]);
          }
        }
      }
    });
  });
}
