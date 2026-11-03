import 'package:flutter/material.dart';

import '../core/nepali_date_utils.dart';
import '../engine/language.dart';
import '../engine/nepali_date.dart';
import '../engine/nepali_date_format.dart';
import '../models/calendar_event.dart';

/// A scrollable agenda: each day that has events, listed in order with its
/// events beneath it.
class NepaliAgendaView extends StatelessWidget {
  /// Creates an agenda view.
  const NepaliAgendaView({
    super.key,
    required this.events,
    this.from,
    this.to,
    this.language = Language.english,
    this.onEventTap,
    this.emptyPlaceholder,
  });

  /// Events keyed by day.
  final Map<NepaliDate, List<CalendarEvent>> events;

  /// Optional lower bound (inclusive). Null = no lower bound.
  final NepaliDate? from;

  /// Optional upper bound (inclusive). Null = no upper bound.
  final NepaliDate? to;

  /// Language for the date headers.
  final Language language;

  /// Tapped an event row.
  final void Function(NepaliDate date, CalendarEvent event)? onEventTap;

  /// Shown when there are no events in range.
  final Widget? emptyPlaceholder;

  @override
  Widget build(BuildContext context) {
    final days = events.keys
        .where((d) => NepaliDateUtils.isWithin(d, min: from, max: to))
        .toList()
      ..sort((a, b) => a.compareTo(b));

    if (days.isEmpty) {
      return emptyPlaceholder ??
          const Center(
              child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No events'),
          ));
    }

    final headerFmt = NepaliDateFormat('EEEE, MMMM d, y', language);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        final dayEvents = events[day] ?? const <CalendarEvent>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
              child: Text(
                headerFmt.format(day),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            for (final event in dayEvents)
              ListTile(
                dense: true,
                leading: Icon(
                  event.isHoliday ? Icons.celebration : Icons.event,
                  color: event.color ??
                      (event.isHoliday
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.tertiary),
                ),
                title: Text(event.title),
                onTap:
                    onEventTap == null ? null : () => onEventTap!(day, event),
              ),
          ],
        );
      },
    );
  }
}
