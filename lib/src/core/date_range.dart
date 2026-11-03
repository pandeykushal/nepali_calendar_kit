import '../engine/nepali_date.dart';
import 'nepali_date_utils.dart';

/// An inclusive range between two Bikram Sambat dates.
///
/// [start] is guaranteed to be on or before [end]; the constructor orders them,
/// so an end-before-start selection is handled rather than rejected.
class NepaliDateRange {
  /// Creates a range from [a] to [b]. The two are ordered automatically.
  NepaliDateRange(NepaliDate a, NepaliDate b)
      : start = a.isAfter(b) ? NepaliDateUtils.dateOnly(b) : NepaliDateUtils.dateOnly(a),
        end = a.isAfter(b) ? NepaliDateUtils.dateOnly(a) : NepaliDateUtils.dateOnly(b);

  /// The earlier endpoint (inclusive), time stripped.
  final NepaliDate start;

  /// The later endpoint (inclusive), time stripped.
  final NepaliDate end;

  /// Whole number of days spanned, inclusive of both endpoints.
  int get durationInDays => end.difference(start).inDays + 1;

  /// `true` if [date] falls on [start], [end], or any day between them.
  bool contains(NepaliDate date) {
    final d = NepaliDateUtils.dateOnly(date);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  /// `true` if [date] is strictly between the endpoints (neither end).
  bool isInterior(NepaliDate date) {
    final d = NepaliDateUtils.dateOnly(date);
    return d.isAfter(start) && d.isBefore(end);
  }

  @override
  bool operator ==(Object other) =>
      other is NepaliDateRange &&
      NepaliDateUtils.isSameDay(other.start, start) &&
      NepaliDateUtils.isSameDay(other.end, end);

  @override
  int get hashCode => Object.hash(
        NepaliDateUtils.dayKey(start),
        NepaliDateUtils.dayKey(end),
      );

  @override
  String toString() =>
      'NepaliDateRange(${NepaliDateUtils.dayKey(start)} → ${NepaliDateUtils.dayKey(end)})';
}
