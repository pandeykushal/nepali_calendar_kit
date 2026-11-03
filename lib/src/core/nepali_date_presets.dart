import '../engine/bs_calendar_data.dart';
import '../engine/nepali_date.dart';
import 'date_range.dart';
import 'nepali_fiscal_year.dart';

/// Common one-tap date ranges for pickers (Today, This week, This FY, ...).
///
/// Each getter is computed relative to [asOf] (defaults to today). Week starts
/// on Sunday, matching Nepali calendars.
class NepaliDatePresets {
  /// Creates presets anchored at [asOf] (defaults to today).
  NepaliDatePresets({NepaliDate? asOf})
      : _today = (asOf ?? NepaliDate.now()).dateOnly;

  final NepaliDate _today;

  /// Just today.
  NepaliDateRange get today => NepaliDateRange(_today, _today);

  /// Just yesterday.
  NepaliDateRange get yesterday {
    final y = _today.subtract(const Duration(days: 1));
    return NepaliDateRange(y, y);
  }

  /// Sunday → Saturday of the current week.
  NepaliDateRange get thisWeek {
    final start = _today.subtract(Duration(days: _today.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return NepaliDateRange(start, end);
  }

  /// Last 7 days ending today.
  NepaliDateRange get last7Days =>
      NepaliDateRange(_today.subtract(const Duration(days: 6)), _today);

  /// First → last day of the current BS month.
  NepaliDateRange get thisMonth => NepaliDateRange(
        NepaliDate(_today.year, _today.month, 1),
        NepaliDate(_today.year, _today.month,
            BsCalendarData.daysInMonth(_today.year, _today.month)),
      );

  /// Last 30 days ending today.
  NepaliDateRange get last30Days =>
      NepaliDateRange(_today.subtract(const Duration(days: 29)), _today);

  /// The whole current fiscal year.
  NepaliDateRange get thisFiscalYear => NepaliFiscalYear.of(_today).range;

  /// The whole previous fiscal year.
  NepaliDateRange get lastFiscalYear {
    final fy = NepaliFiscalYear.of(_today);
    return NepaliFiscalYear.of(fy.start.subtract(const Duration(days: 1))).range;
  }

  /// The current fiscal quarter.
  NepaliDateRange get thisQuarter {
    final fy = NepaliFiscalYear.of(_today);
    return fy.quarter(NepaliFiscalYear.quarterOf(_today));
  }

  /// A labeled list suitable for a chip/menu row in a picker.
  ///
  /// Labels are English; wrap or translate as needed in your UI.
  Map<String, NepaliDateRange> get labeled => <String, NepaliDateRange>{
        'Today': today,
        'Yesterday': yesterday,
        'This week': thisWeek,
        'Last 7 days': last7Days,
        'This month': thisMonth,
        'Last 30 days': last30Days,
        'This quarter': thisQuarter,
        'This FY': thisFiscalYear,
        'Last FY': lastFiscalYear,
      };
}
