import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import '../engine/language.dart';
import '../engine/nepali_date.dart';

import '../core/nepali_date_utils.dart';
import '../l10n/calendar_labels.dart';

/// An iOS-style three-wheel (year / month / day) Bikram Sambat picker.
///
/// The day wheel re-clamps itself whenever the selected year or month changes
/// so an invalid day (e.g. day 32 in a 30-day month) can never be produced.
class CupertinoNepaliDatePicker extends StatefulWidget {
  /// Creates the wheel picker.
  const CupertinoNepaliDatePicker({
    super.key,
    required this.initialDate,
    this.firstDate,
    this.lastDate,
    this.language,
    this.onDateChanged,
  });

  /// Date the wheels start on.
  final NepaliDate initialDate;

  /// Earliest selectable year bound.
  final NepaliDate? firstDate;

  /// Latest selectable year bound.
  final NepaliDate? lastDate;

  /// Active language.
  final Language? language;

  /// Fired on every wheel change with the current composed date.
  final void Function(NepaliDate date)? onDateChanged;

  @override
  State<CupertinoNepaliDatePicker> createState() =>
      _CupertinoNepaliDatePickerState();
}

class _CupertinoNepaliDatePickerState extends State<CupertinoNepaliDatePicker> {
  late int _year = widget.initialDate.year;
  late int _month = widget.initialDate.month;
  late int _day = widget.initialDate.day;

  int get _minYear => widget.firstDate?.year ?? kNckMinBsYear;
  int get _maxYear => widget.lastDate?.year ?? kNckMaxBsYear;

  Language get _lang => widget.language ?? Language.english;

  void _emit() {
    final maxDay = NepaliDateUtils.daysInMonth(_year, _month);
    if (_day > maxDay) _day = maxDay;
    widget.onDateChanged?.call(NepaliDate(_year, _month, _day));
  }

  @override
  Widget build(BuildContext context) {
    final years = <int>[for (var y = _minYear; y <= _maxYear; y++) y];
    final daysInMonth = NepaliDateUtils.daysInMonth(_year, _month);
    final textStyle = Theme.of(context).textTheme.titleMedium;

    return SizedBox(
      height: 216,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: _year - _minYear,
              ),
              itemExtent: 36,
              onSelectedItemChanged: (i) {
                setState(() => _year = years[i]);
                _emit();
              },
              children: <Widget>[
                for (final y in years)
                  Center(
                    child: Text(
                      NepaliCalendarLabels.digits(y, _lang),
                      style: textStyle,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: CupertinoPicker(
              scrollController:
                  FixedExtentScrollController(initialItem: _month - 1),
              itemExtent: 36,
              onSelectedItemChanged: (i) {
                setState(() => _month = i + 1);
                _emit();
              },
              children: <Widget>[
                for (var m = 1; m <= 12; m++)
                  Center(
                    child: Text(
                      NepaliCalendarLabels.monthName(m, _lang),
                      style: textStyle,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: (_day - 1).clamp(0, daysInMonth - 1),
              ),
              itemExtent: 36,
              onSelectedItemChanged: (i) {
                setState(() => _day = i + 1);
                _emit();
              },
              children: <Widget>[
                for (var d = 1; d <= daysInMonth; d++)
                  Center(
                    child: Text(
                      NepaliCalendarLabels.digits(d, _lang),
                      style: textStyle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
