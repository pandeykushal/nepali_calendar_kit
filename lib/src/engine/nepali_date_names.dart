import 'language.dart';

/// Month, weekday and digit data for both languages - the engine's own copy,
/// with no dependency on any third-party package.
abstract final class NepaliDateNames {
  /// BS month names, Baisakh (index 0) → Chaitra (index 11), English.
  static const List<String> monthsEn = <String>[
    'Baisakh',
    'Jestha',
    'Ashadh',
    'Shrawan',
    'Bhadra',
    'Ashwin',
    'Kartik',
    'Mangsir',
    'Poush',
    'Magh',
    'Falgun',
    'Chaitra',
  ];

  /// BS month names, Baisakh (index 0) → Chaitra (index 11), Nepali.
  static const List<String> monthsNp = <String>[
    'बैशाख',
    'जेठ',
    'असार',
    'साउन',
    'भदौ',
    'असोज',
    'कार्तिक',
    'मंसिर',
    'पुष',
    'माघ',
    'फागुन',
    'चैत',
  ];

  /// Full weekday names, Sunday (index 0) → Saturday (index 6), English.
  static const List<String> weekdaysEn = <String>[
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  /// Short weekday names, Sunday → Saturday, English.
  static const List<String> weekdaysShortEn = <String>[
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  /// Full weekday names, Sunday → Saturday, Nepali.
  static const List<String> weekdaysNp = <String>[
    'आइतबार',
    'सोमबार',
    'मंगलबार',
    'बुधबार',
    'बिहिबार',
    'शुक्रबार',
    'शनिबार',
  ];

  /// Short weekday headers, Sunday → Saturday, Nepali.
  static const List<String> weekdaysShortNp = <String>[
    'आ',
    'सो',
    'मं',
    'बु',
    'बि',
    'शु',
    'श',
  ];

  static const List<String> _devanagariDigits = <String>[
    '०',
    '१',
    '२',
    '३',
    '४',
    '५',
    '६',
    '७',
    '८',
    '९',
  ];

  /// Month name for 1-based [month] in [language].
  static String month(int month, Language language) =>
      (language == Language.nepali ? monthsNp : monthsEn)[(month - 1) % 12];

  /// Full weekday name for 1-based [weekday] (Sun=1..Sat=7) in [language].
  static String weekday(int weekday, Language language) =>
      (language == Language.nepali
          ? weekdaysNp
          : weekdaysEn)[(weekday - 1) % 7];

  /// Short weekday name for 1-based [weekday] in [language].
  static String weekdayShort(int weekday, Language language) =>
      (language == Language.nepali
          ? weekdaysShortNp
          : weekdaysShortEn)[(weekday - 1) % 7];

  /// Weekday header list (index 0 = Sunday) for [language].
  static List<String> weekdayHeaders(Language language) =>
      language == Language.nepali ? weekdaysShortNp : weekdaysShortEn;

  /// Renders an integer in [language]'s digits, with no grouping separators.
  static String digits(int value, Language language) {
    final ascii = value.toString();
    if (language != Language.nepali) return ascii;
    final buffer = StringBuffer();
    for (final unit in ascii.codeUnits) {
      if (unit >= 0x30 && unit <= 0x39) {
        buffer.write(_devanagariDigits[unit - 0x30]);
      } else {
        buffer.writeCharCode(unit);
      }
    }
    return buffer.toString();
  }
}
