import 'language.dart';
import 'nepali_date.dart';
import 'nepali_date_names.dart';

/// Human "time ago / from now" text for BS dates, in Nepali or English.
///
/// Examples (Nepali): आज, हिजो, भोलि, अस्ति, पर्सि, `३ दिन अगाडि`, `२ हप्ता पछि`.
abstract final class NepaliRelativeTime {
  /// Relative phrase for [date] compared to [reference] (defaults to now).
  static String format(
    NepaliDate date, {
    NepaliDate? reference,
    Language language = Language.english,
  }) {
    final ref = (reference ?? NepaliDate.now()).dateOnly;
    final d = date.dateOnly.difference(ref).inDays;
    final np = language == Language.nepali;

    if (d == 0) return np ? 'आज' : 'today';
    if (d == -1) return np ? 'हिजो' : 'yesterday';
    if (d == 1) return np ? 'भोलि' : 'tomorrow';
    if (d == -2) return np ? 'अस्ति' : '2 days ago';
    if (d == 2) return np ? 'पर्सि' : 'in 2 days';

    final past = d < 0;
    final n = d.abs();

    int value;
    String enUnit, npUnit;
    if (n < 7) {
      value = n;
      enUnit = 'day';
      npUnit = 'दिन';
    } else if (n < 30) {
      value = n ~/ 7;
      enUnit = 'week';
      npUnit = 'हप्ता';
    } else if (n < 365) {
      value = n ~/ 30;
      enUnit = 'month';
      npUnit = 'महिना';
    } else {
      value = n ~/ 365;
      enUnit = 'year';
      npUnit = 'वर्ष';
    }

    if (np) {
      final num = NepaliDateNames.digits(value, Language.nepali);
      return past ? '$num $npUnit अगाडि' : '$num $npUnit पछि';
    }
    final plural = value == 1 ? enUnit : '${enUnit}s';
    return past ? '$value $plural ago' : 'in $value $plural';
  }
}
