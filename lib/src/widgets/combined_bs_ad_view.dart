import 'package:flutter/material.dart';
import '../engine/language.dart';
import '../engine/nepali_date.dart';
import '../engine/nepali_date_format.dart';

import '../core/nepali_date_utils.dart';
import '../models/selection_mode.dart';
import '../theme/nepali_calendar_theme.dart';
import 'nepali_calendar.dart';

/// A calendar with a live BS ⇄ AD readout above it.
///
/// Tapping a day in the BS grid updates the AD equivalent (and vice-versa
/// through the AD/BS summary chips). This is the package's signature
/// differentiator - both calendars synced in one widget.
class CombinedBsAdView extends StatefulWidget {
  /// Creates the combined view.
  const CombinedBsAdView({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
    this.theme,
    this.language,
  });

  /// Date to open on. Defaults to today.
  final NepaliDate? initialDate;

  /// Earliest selectable date.
  final NepaliDate? firstDate;

  /// Latest selectable date.
  final NepaliDate? lastDate;

  /// Fired with the chosen BS date on each tap.
  final void Function(NepaliDate bs, DateTime ad)? onDateChanged;

  /// Visual overrides.
  final NepaliCalendarTheme? theme;

  /// Active language.
  final Language? language;

  @override
  State<CombinedBsAdView> createState() => _CombinedBsAdViewState();
}

class _CombinedBsAdViewState extends State<CombinedBsAdView> {
  late NepaliDate _selected =
      widget.initialDate ?? NepaliDateUtils.today();

  @override
  Widget build(BuildContext context) {
    final ad = _selected.toDateTime();
    final lang = widget.language ?? Language.english;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _DateChip(
                label: 'Bikram Sambat',
                value: NepaliDateFormat('EEE, MMMM d, y', lang).format(_selected),
                icon: Icons.calendar_month,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DateChip(
                label: 'Gregorian (AD)',
                value: _formatAd(ad),
                icon: Icons.public,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        NepaliCalendar(
          initialDate: _selected,
          selectedDate: _selected,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectionMode: NepaliSelectionMode.single,
          theme: widget.theme,
          language: widget.language,
          onDateChanged: (date) {
            setState(() => _selected = date);
            widget.onDateChanged?.call(date, date.toDateTime());
          },
        ),
      ],
    );
  }

  String _formatAd(DateTime ad) {
    const months = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekdays = <String>[
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    return '${weekdays[ad.weekday - 1]}, ${months[ad.month - 1]} ${ad.day}, ${ad.year}';
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
