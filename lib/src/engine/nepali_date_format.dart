import 'language.dart';
import 'nepali_date.dart';
import 'nepali_date_names.dart';

/// Formats a [NepaliDate] with a pattern string - the engine's own formatter,
/// no third-party dependency.
///
/// Supported tokens (longest-match first):
///
/// | Token | Meaning | Example (2081-07-03, Sat) |
/// |---|---|---|
/// | `yyyy` / `y` | year | 2081 |
/// | `yy` | 2-digit year | 81 |
/// | `MMMM` | full month | Kartik |
/// | `MMM` | short month (same list) | Kartik |
/// | `MM` | 2-digit month | 07 |
/// | `M` | month | 7 |
/// | `dd` | 2-digit day | 03 |
/// | `d` | day | 3 |
/// | `EEEE` | full weekday | Saturday |
/// | `EEE` / `EE` / `E` | short weekday | Sat |
/// | `HH`/`H` `mm`/`m` `ss`/`s` | time parts | 09 / 05 / 00 |
///
/// Digits are localized to the active [Language]. Wrap literal text in single
/// quotes: `"yyyy 'साल'"`. Use `''` for a literal apostrophe.
class NepaliDateFormat {
  /// Creates a formatter from a [pattern] and optional [language]
  /// (defaults to English).
  const NepaliDateFormat(this.pattern, [this.language = Language.english]);

  /// The pattern string.
  final String pattern;

  /// Language for names and digits.
  final Language language;

  static const List<String> _tokens = <String>[
    'yyyy', 'yy', 'y',
    'MMMM', 'MMM', 'MM', 'M',
    'dd', 'd',
    'EEEE', 'EEE', 'EE', 'E',
    'HH', 'H', 'mm', 'm', 'ss', 's',
  ];

  /// Formats [date] according to [pattern].
  String format(NepaliDate date) {
    final out = StringBuffer();
    var i = 0;
    while (i < pattern.length) {
      final ch = pattern[i];

      if (ch == "'") {
        i++;
        if (i < pattern.length && pattern[i] == "'") {
          out.write("'");
          i++;
          continue;
        }
        while (i < pattern.length && pattern[i] != "'") {
          out.write(pattern[i]);
          i++;
        }
        i++;
        continue;
      }

      final token = _matchToken(i);
      if (token == null) {
        out.write(ch);
        i++;
        continue;
      }
      out.write(_expand(token, date));
      i += token.length;
    }
    return out.toString();
  }

  String? _matchToken(int index) {
    for (final t in _tokens) {
      if (pattern.startsWith(t, index)) return t;
    }
    return null;
  }

  /// Parses [input] according to [pattern]. Accepts Devanagari or ASCII digits
  /// and localized month names. Throws [FormatException] on failure.
  NepaliDate parse(String input) {
    final result = tryParse(input);
    if (result == null) {
      throw FormatException('Does not match pattern "$pattern"', input);
    }
    return result;
  }

  /// Like [parse] but returns null instead of throwing.
  NepaliDate? tryParse(String input) {
    final regex = StringBuffer('^');
    final fields = <String>[];
    var i = 0;
    while (i < pattern.length) {
      final ch = pattern[i];
      if (ch == "'") {
        i++;
        if (i < pattern.length && pattern[i] == "'") {
          regex.write(RegExp.escape("'"));
          i++;
          continue;
        }
        while (i < pattern.length && pattern[i] != "'") {
          regex.write(RegExp.escape(pattern[i]));
          i++;
        }
        i++;
        continue;
      }
      final token = _matchToken(i);
      if (token == null) {
        regex.write(RegExp.escape(ch));
        i++;
        continue;
      }
      i += token.length;
      switch (token) {
        case 'yyyy':
        case 'y':
          regex.write(r'(\d{1,4})');
          fields.add('y');
        case 'yy':
          regex.write(r'(\d{2})');
          fields.add('yy');
        case 'MMMM':
        case 'MMM':
          final names = [
            ...NepaliDateNames.monthsEn,
            ...NepaliDateNames.monthsNp,
          ].map(RegExp.escape).join('|');
          regex.write('($names)');
          fields.add('MMMM');
        case 'MM':
        case 'M':
          regex.write(r'(\d{1,2})');
          fields.add('M');
        case 'dd':
        case 'd':
          regex.write(r'(\d{1,2})');
          fields.add('d');
        case 'HH':
        case 'H':
          regex.write(r'(\d{1,2})');
          fields.add('H');
        case 'mm':
        case 'm':
          regex.write(r'(\d{1,2})');
          fields.add('m');
        case 'ss':
        case 's':
          regex.write(r'(\d{1,2})');
          fields.add('s');
        case 'EEEE':
        case 'EEE':
        case 'EE':
        case 'E':
          final names = [
            ...NepaliDateNames.weekdaysEn,
            ...NepaliDateNames.weekdaysShortEn,
            ...NepaliDateNames.weekdaysNp,
            ...NepaliDateNames.weekdaysShortNp,
          ].map(RegExp.escape).join('|');
          regex.write('(?:$names)');
      }
    }
    regex.write(r'$');

    final ascii = _toAsciiDigits(input.trim());
    final match = RegExp(regex.toString()).firstMatch(ascii);
    if (match == null) return null;

    var year = 0, month = 1, day = 1, hour = 0, minute = 0, second = 0;
    for (var g = 0; g < fields.length; g++) {
      final value = match.group(g + 1)!;
      switch (fields[g]) {
        case 'y':
          year = int.parse(value);
        case 'yy':
          year = 2000 + int.parse(value);
        case 'MMMM':
          final idx = NepaliDateNames.monthsEn.indexOf(value);
          month = idx >= 0 ? idx + 1 : NepaliDateNames.monthsNp.indexOf(value) + 1;
        case 'M':
          month = int.parse(value);
        case 'd':
          day = int.parse(value);
        case 'H':
          hour = int.parse(value);
        case 'm':
          minute = int.parse(value);
        case 's':
          second = int.parse(value);
      }
    }
    final date = NepaliDate(year, month, day, hour, minute, second);
    if (!date.isValid || hour > 23 || minute > 59 || second > 59) return null;
    return date;
  }

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

  String _expand(String token, NepaliDate d) {
    switch (token) {
      case 'yyyy':
      case 'y':
        return NepaliDateNames.digits(d.year, language);
      case 'yy':
        return NepaliDateNames.digits(d.year % 100, language).padLeft(2, '0');
      case 'MMMM':
      case 'MMM':
        return NepaliDateNames.month(d.month, language);
      case 'MM':
        return _twoDigits(d.month);
      case 'M':
        return NepaliDateNames.digits(d.month, language);
      case 'dd':
        return _twoDigits(d.day);
      case 'd':
        return NepaliDateNames.digits(d.day, language);
      case 'EEEE':
        return NepaliDateNames.weekday(d.weekday, language);
      case 'EEE':
      case 'EE':
      case 'E':
        return NepaliDateNames.weekdayShort(d.weekday, language);
      case 'HH':
        return _twoDigits(d.hour);
      case 'H':
        return NepaliDateNames.digits(d.hour, language);
      case 'mm':
        return _twoDigits(d.minute);
      case 'm':
        return NepaliDateNames.digits(d.minute, language);
      case 'ss':
        return _twoDigits(d.second);
      case 's':
        return NepaliDateNames.digits(d.second, language);
      default:
        return token;
    }
  }

  String _twoDigits(int n) {
    final s = n.toString().padLeft(2, '0');
    if (language != Language.nepali) return s;
    return NepaliDateNames.digits(n, language).padLeft(2, NepaliDateNames.digits(0, language));
  }
}
