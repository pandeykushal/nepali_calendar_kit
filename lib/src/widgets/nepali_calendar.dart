import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/language.dart';
import '../engine/nepali_date.dart';

import '../core/date_range.dart';
import '../core/nepali_date_utils.dart';
import '../core/nepali_month_grid.dart';
import '../models/calendar_event.dart';
import '../models/selection_mode.dart';
import '../theme/nepali_calendar_theme.dart';
import 'calendar_builders.dart';
import 'calendar_header.dart';
import 'nepali_day_cell.dart';
import 'weekday_header.dart';

/// Signature for range-selection changes. Either value may be null while a
/// range is mid-selection (start chosen, end pending).
typedef NepaliRangeChanged = void Function(NepaliDateRange? range);

/// An inline, embeddable Bikram Sambat calendar.
///
/// Drop it into any layout. It supports single and range selection, arbitrary
/// disabled dates, a min/max window, event markers, custom cell/header
/// builders, Nepali/English localization, and Material 3 theming with dark
/// mode. All BS↔AD math uses the package's own built-in engine.
///
/// For a modal picker use `showNepaliDatePicker`; this widget is the inline
/// surface those pickers are built on and can also be used on its own.
class NepaliCalendar extends StatefulWidget {
  /// Creates an inline calendar.
  const NepaliCalendar({
    super.key,
    this.initialDate,
    this.selectedDate,
    this.selectedRange,
    this.firstDate,
    this.lastDate,
    this.selectionMode = NepaliSelectionMode.single,
    this.onDateChanged,
    this.onRangeChanged,
    this.selectedDates,
    this.onMultiChanged,
    this.disabledDates,
    this.selectableDayPredicate,
    this.events,
    this.theme,
    this.language,
    this.showAdDate = false,
    this.highlightWeekends = true,
    this.highlightHolidays = true,
    this.enableHaptics = true,
    this.animateMonthChange = true,
    this.dayBuilder,
    this.headerBuilder,
  });

  /// Month to open on / fallback selection anchor. Defaults to today.
  final NepaliDate? initialDate;

  /// Currently selected day in [NepaliSelectionMode.single].
  final NepaliDate? selectedDate;

  /// Currently selected range in [NepaliSelectionMode.range].
  final NepaliDateRange? selectedRange;

  /// Earliest selectable date (inclusive). Null means unbounded.
  final NepaliDate? firstDate;

  /// Latest selectable date (inclusive). Null means unbounded.
  final NepaliDate? lastDate;

  /// Single vs range vs multiple vs display-only.
  final NepaliSelectionMode selectionMode;

  /// Called when the single selection changes.
  final NepaliDateChanged? onDateChanged;

  /// Called when the range selection changes.
  final NepaliRangeChanged? onRangeChanged;

  /// Pre-selected days in [NepaliSelectionMode.multiple].
  final Set<NepaliDate>? selectedDates;

  /// Called with the full selected set in [NepaliSelectionMode.multiple].
  final void Function(Set<NepaliDate> dates)? onMultiChanged;

  /// Specific dates to grey out, beyond the [firstDate]/[lastDate] window.
  final Set<NepaliDate>? disabledDates;

  /// Return false to block a date. Runs in addition to [disabledDates] and the
  /// min/max window.
  final bool Function(NepaliDate date)? selectableDayPredicate;

  /// Markers to render, keyed by day. Indexed internally for O(1) lookup.
  final Map<NepaliDate, List<CalendarEvent>>? events;

  /// Visual overrides. Anything null is resolved from the ambient theme.
  final NepaliCalendarTheme? theme;

  /// Language for numerals and names. Defaults to [Language.english].
  final Language? language;

  /// Show the equivalent AD date under the header.
  final bool showAdDate;

  /// Tint Saturdays with the weekend color.
  final bool highlightWeekends;

  /// Tint days that carry a holiday event with the holiday color.
  final bool highlightHolidays;

  /// Fire a light haptic on selection.
  final bool enableHaptics;

  /// Animate (slide + fade) when the visible month changes.
  final bool animateMonthChange;

  /// Build a custom cell; return null to use the default for a given day.
  final NepaliDayBuilder? dayBuilder;

  /// Build a custom header; return null to use the default.
  final NepaliHeaderBuilder? headerBuilder;

  @override
  State<NepaliCalendar> createState() => _NepaliCalendarState();
}

class _NepaliCalendarState extends State<NepaliCalendar> {
  late NepaliDate _visibleMonth;
  NepaliDate? _selected;
  NepaliDate? _rangeStart;
  NepaliDate? _rangeEnd;
  final Set<String> _multiKeys = <String>{};
  final List<NepaliDate> _multiDates = <NepaliDate>[];
  late Map<String, List<CalendarEvent>> _eventIndex;
  int _pageDirection = 0;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedDate == null
        ? null
        : NepaliDateUtils.dateOnly(widget.selectedDate!);
    _rangeStart = widget.selectedRange?.start;
    _rangeEnd = widget.selectedRange?.end;
    if (widget.selectedDates != null) {
      for (final d in widget.selectedDates!) {
        final key = NepaliDateUtils.dayKey(d);
        if (_multiKeys.add(key)) _multiDates.add(NepaliDateUtils.dateOnly(d));
      }
    }

    final anchor = widget.selectedDate ??
        widget.selectedRange?.start ??
        widget.initialDate ??
        NepaliDateUtils.today();
    _visibleMonth = NepaliDateUtils.clamp(
      NepaliDate(anchor.year, anchor.month),
      min: widget.firstDate == null
          ? null
          : NepaliDate(widget.firstDate!.year, widget.firstDate!.month),
      max: widget.lastDate == null
          ? null
          : NepaliDate(widget.lastDate!.year, widget.lastDate!.month),
    );
    _rebuildEventIndex();
  }

  @override
  void didUpdateWidget(NepaliCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.events, widget.events)) _rebuildEventIndex();
    if (oldWidget.selectedDate != widget.selectedDate) {
      _selected = widget.selectedDate == null
          ? null
          : NepaliDateUtils.dateOnly(widget.selectedDate!);
    }
    if (oldWidget.selectedRange != widget.selectedRange) {
      _rangeStart = widget.selectedRange?.start;
      _rangeEnd = widget.selectedRange?.end;
    }
  }

  void _rebuildEventIndex() {
    _eventIndex = <String, List<CalendarEvent>>{};
    final source = widget.events;
    if (source == null) return;
    source.forEach((date, list) {
      _eventIndex[NepaliDateUtils.dayKey(date)] = list;
    });
  }

  Language get _language =>
      widget.language ?? Language.english;

  int get _minYear => widget.firstDate?.year ?? kNckMinBsYear;
  int get _maxYear => widget.lastDate?.year ?? kNckMaxBsYear;

  bool _isDisabled(NepaliDate date) {
    if (!NepaliDateUtils.isWithin(date,
        min: widget.firstDate, max: widget.lastDate)) {
      return true;
    }
    if (widget.disabledDates != null) {
      for (final d in widget.disabledDates!) {
        if (NepaliDateUtils.isSameDay(d, date)) return true;
      }
    }
    if (widget.selectableDayPredicate != null &&
        !widget.selectableDayPredicate!(date)) {
      return true;
    }
    return false;
  }

  void _goToMonth(NepaliDate month) {
    final target = NepaliDate(month.year, month.month);
    setState(() {
      _pageDirection = target.isAfter(_visibleMonth)
          ? 1
          : target.isBefore(_visibleMonth)
              ? -1
              : 0;
      _visibleMonth = target;
    });
  }

  bool get _canGoPrevious {
    if (widget.firstDate == null) return _visibleMonth.year > kNckMinBsYear;
    final prev = NepaliDateUtils.addMonths(_visibleMonth, -1);
    final lastOfPrev = NepaliDate(
      prev.year,
      prev.month,
      NepaliDateUtils.daysInMonth(prev.year, prev.month),
    );
    return !lastOfPrev.isBefore(NepaliDateUtils.dateOnly(widget.firstDate!));
  }

  bool get _canGoNext {
    if (widget.lastDate == null) return _visibleMonth.year < kNckMaxBsYear;
    final next = NepaliDateUtils.addMonths(_visibleMonth, 1);
    final firstOfNext = NepaliDate(next.year, next.month);
    return !firstOfNext.isAfter(NepaliDateUtils.dateOnly(widget.lastDate!));
  }

  void _handleTap(NepaliDate date) {
    if (_isDisabled(date)) return;
    if (widget.enableHaptics) HapticFeedback.selectionClick();
    final tapped = NepaliDateUtils.dateOnly(date);

    switch (widget.selectionMode) {
      case NepaliSelectionMode.none:
        return;
      case NepaliSelectionMode.single:
        setState(() => _selected = tapped);
        widget.onDateChanged?.call(tapped);
      case NepaliSelectionMode.range:
        setState(() {
          if (_rangeStart == null || _rangeEnd != null) {
            _rangeStart = tapped;
            _rangeEnd = null;
          } else {
            _rangeEnd = tapped;
          }
        });
        if (_rangeStart != null && _rangeEnd != null) {
          widget.onRangeChanged?.call(NepaliDateRange(_rangeStart!, _rangeEnd!));
        } else {
          widget.onRangeChanged?.call(null);
        }
      case NepaliSelectionMode.multiple:
        final key = NepaliDateUtils.dayKey(tapped);
        setState(() {
          if (_multiKeys.remove(key)) {
            _multiDates.removeWhere((d) => NepaliDateUtils.dayKey(d) == key);
          } else {
            _multiKeys.add(key);
            _multiDates.add(tapped);
          }
        });
        widget.onMultiChanged?.call(_multiDates.toSet());
    }
  }

  NepaliDayContext _contextFor(NepaliGridDay cell) {
    final date = cell.date;
    final today = NepaliDateUtils.today();

    var isSelected = false;
    var isRangeStart = false;
    var isRangeEnd = false;
    var isInRange = false;

    if (widget.selectionMode == NepaliSelectionMode.single) {
      isSelected = _selected != null &&
          NepaliDateUtils.isSameDay(_selected!, date);
    } else if (widget.selectionMode == NepaliSelectionMode.range) {
      if (_rangeStart != null && _rangeEnd != null) {
        final range = NepaliDateRange(_rangeStart!, _rangeEnd!);
        isRangeStart = NepaliDateUtils.isSameDay(range.start, date);
        isRangeEnd = NepaliDateUtils.isSameDay(range.end, date);
        isSelected = isRangeStart || isRangeEnd;
        isInRange = range.isInterior(date);
      } else if (_rangeStart != null) {
        isRangeStart = NepaliDateUtils.isSameDay(_rangeStart!, date);
        isSelected = isRangeStart;
      }
    } else if (widget.selectionMode == NepaliSelectionMode.multiple) {
      isSelected = _multiKeys.contains(NepaliDateUtils.dayKey(date));
    }

    final events =
        _eventIndex[NepaliDateUtils.dayKey(date)] ?? const <CalendarEvent>[];
    final isHoliday = widget.highlightHolidays &&
        events.any((e) => e.isHoliday);

    return NepaliDayContext(
      date: date,
      isInMonth: cell.inMonth,
      isToday: NepaliDateUtils.isSameDay(today, date),
      isSelected: isSelected,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
      isInRange: isInRange,
      isDisabled: _isDisabled(date),
      isWeekend: widget.highlightWeekends && NepaliDateUtils.isWeekend(date),
      isHoliday: isHoliday,
      events: events,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = (widget.theme ?? const NepaliCalendarTheme()).resolve(context);
    final grid = NepaliMonthGrid(_visibleMonth.year, _visibleMonth.month);

    final header = widget.headerBuilder?.call(context, _visibleMonth) ??
        NepaliCalendarHeader(
          visibleMonth: _visibleMonth,
          language: _language,
          resolvedTheme: resolved,
          canGoPrevious: _canGoPrevious,
          canGoNext: _canGoNext,
          onPrevious: () => _goToMonth(
            NepaliDateUtils.addMonths(_visibleMonth, -1),
          ),
          onNext: () => _goToMonth(
            NepaliDateUtils.addMonths(_visibleMonth, 1),
          ),
          onTapTitle: () async {
            final picked = await showNepaliMonthYearPicker(
              context: context,
              initialMonth: _visibleMonth,
              minYear: _minYear,
              maxYear: _maxYear,
              language: _language,
            );
            if (picked != null) _goToMonth(picked);
          },
        );

    return Container(
      decoration: BoxDecoration(
        color: resolved.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          header,
          if (widget.showAdDate) _AdSubtitle(month: _visibleMonth),
          const SizedBox(height: 4),
          NepaliWeekdayHeader(language: _language, resolvedTheme: resolved),
          const SizedBox(height: 4),
          if (widget.animateMonthChange)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: Offset(0.15 * _pageDirection, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<String>('${_visibleMonth.year}-${_visibleMonth.month}'),
                child: _Grid(
                  grid: grid,
                  contextFor: _contextFor,
                  onTap: _handleTap,
                  builder: widget.dayBuilder,
                  language: _language,
                  resolvedTheme: resolved,
                ),
              ),
            )
          else
            _Grid(
              grid: grid,
              contextFor: _contextFor,
              onTap: _handleTap,
              builder: widget.dayBuilder,
              language: _language,
              resolvedTheme: resolved,
            ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.grid,
    required this.contextFor,
    required this.onTap,
    required this.builder,
    required this.language,
    required this.resolvedTheme,
  });

  final NepaliMonthGrid grid;
  final NepaliDayContext Function(NepaliGridDay) contextFor;
  final void Function(NepaliDate) onTap;
  final NepaliDayBuilder? builder;
  final Language language;
  final NepaliCalendarTheme resolvedTheme;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: grid.days.length,
      itemBuilder: (context, index) {
        final cell = grid.days[index];
        final dayCtx = contextFor(cell);
        final custom = builder?.call(context, dayCtx);
        final child = custom ??
            NepaliDayCell(
              day: dayCtx,
              language: language,
              resolvedTheme: resolvedTheme,
            );
        return InkWell(
          onTap: dayCtx.isDisabled ? null : () => onTap(cell.date),
          customBorder: const CircleBorder(),
          child: child,
        );
      },
    );
  }
}

class _AdSubtitle extends StatelessWidget {
  const _AdSubtitle({required this.month});

  final NepaliDate month;

  @override
  Widget build(BuildContext context) {
    final ad = month.toDateTime();
    const adMonths = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '${adMonths[ad.month - 1]} ${ad.year}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
