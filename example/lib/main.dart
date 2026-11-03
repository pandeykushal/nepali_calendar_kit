import 'package:flutter/material.dart';
import 'package:nepali_calendar_kit/nepali_calendar_kit.dart';

void main() {
  runApp(const DemoApp());
}

/// Root demo app with a light/dark toggle.
class DemoApp extends StatefulWidget {
  /// Creates the demo app.
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  ThemeMode _mode = ThemeMode.light;
  Language _lang = Language.english;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFDC143C);
    return MaterialApp(
      title: 'nepali_calendar_kit demo',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: DemoHome(
        isDark: _mode == ThemeMode.dark,
        language: _lang,
        onToggleTheme: () => setState(
          () => _mode =
              _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
        ),
        onToggleLang: () => setState(
          () => _lang =
              _lang == Language.nepali ? Language.english : Language.nepali,
        ),
      ),
    );
  }
}

/// Home screen with one section per feature.
class DemoHome extends StatefulWidget {
  /// Creates the home screen.
  const DemoHome({
    super.key,
    required this.isDark,
    required this.language,
    required this.onToggleTheme,
    required this.onToggleLang,
  });

  /// Whether dark mode is active (for the toggle icon).
  final bool isDark;

  /// Active language.
  final Language language;

  /// Flip the theme.
  final VoidCallback onToggleTheme;

  /// Flip the language.
  final VoidCallback onToggleLang;

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  NepaliDate? _single;
  NepaliDateRange? _range;
  NepaliDate? _formValue;
  int _multiCount = 0;
  NepaliDate? _dateTime;
  NepaliDate? _typed;
  NepaliDate _weekAnchor = NepaliDateUtils.today();
  final _formKey = GlobalKey<FormState>();

  late final Map<NepaliDate, List<CalendarEvent>> _events = {
    NepaliDateUtils.today(): const [
      CalendarEvent(title: 'Today reminder'),
    ],
    NepaliDateUtils.today().add(const Duration(days: 2)): const [
      CalendarEvent(title: 'Dashain', isHoliday: true),
      CalendarEvent(title: 'Family lunch'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('nepali_calendar_kit'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Toggle language',
            onPressed: widget.onToggleLang,
            icon: const Icon(Icons.translate),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _section(
            '0 · BS ⇄ AD date converter',
            DateConverterSection(language: widget.language),
          ),
          _section(
            '1 · showNepaliDatePicker() - adaptive dialog',
            Row(
              children: <Widget>[
                FilledButton(
                  onPressed: () async {
                    final picked = await showNepaliDatePicker(
                      context: context,
                      initialDate: NepaliDateUtils.today(),
                      firstDate: NepaliDate(2075),
                      lastDate: NepaliDate(2090),
                      language: widget.language,
                      events: _events,
                    );
                    if (picked != null) setState(() => _single = picked);
                  },
                  child: const Text('Pick a date'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _single == null
                        ? 'No date'
                        : NepaliDateFormat('EEE, MMMM d, y', widget.language)
                            .format(_single!),
                  ),
                ),
              ],
            ),
          ),
          _section(
            '2 · Range picker',
            Row(
              children: <Widget>[
                FilledButton.tonal(
                  onPressed: () async {
                    final picked = await showNepaliDateRangePicker(
                      context: context,
                      firstDate: NepaliDate(2075),
                      lastDate: NepaliDate(2090),
                      language: widget.language,
                    );
                    if (picked != null) setState(() => _range = picked);
                  },
                  child: const Text('Pick a range'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _range == null
                        ? 'No range'
                        : '${_range!.durationInDays} days',
                  ),
                ),
              ],
            ),
          ),
          _section(
            '3 · Combined BS + AD live view',
            CombinedBsAdView(
              language: widget.language,
              firstDate: NepaliDate(2070),
              lastDate: NepaliDate(2095),
            ),
          ),
          _section(
            '4 · Inline calendar with event markers',
            NepaliCalendar(
              language: widget.language,
              selectionMode: NepaliSelectionMode.single,
              showAdDate: true,
              events: _events,
              onDateChanged: (d) {},
            ),
          ),
          _section(
            '5 · Custom day-cell builder',
            NepaliCalendar(
              language: widget.language,
              selectionMode: NepaliSelectionMode.none,
              dayBuilder: (context, day) {
                if (!day.isInMonth) return null;
                return Center(
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: day.isWeekend
                        ? Colors.red.withValues(alpha: 0.15)
                        : Colors.transparent,
                    child: Text(
                      NepaliCalendarLabels.digits(
                          day.date.day, widget.language),
                      style: TextStyle(
                        fontSize: 12,
                        color: day.isWeekend ? Colors.red : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _section(
            '6 · Disabled dates (block all Saturdays)',
            NepaliCalendar(
              language: widget.language,
              selectableDayPredicate: (date) => date.weekday != 7,
            ),
          ),
          _section(
            '7 · NepaliDateFormField in a Form',
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  NepaliDateFormField(
                    language: widget.language,
                    decoration: const InputDecoration(
                      labelText: 'Date of birth',
                      border: OutlineInputBorder(),
                    ),
                    firstDate: NepaliDate(2000),
                    lastDate: NepaliDate.now(),
                    validator: (d) => d == null ? 'Required' : null,
                    onSaved: (d) => _formValue = d,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Saved: $_formValue'),
                          ),
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
          _section(
            '8 · Multi-date (non-contiguous) selection - $_multiCount selected',
            NepaliCalendar(
              language: widget.language,
              selectionMode: NepaliSelectionMode.multiple,
              onMultiChanged: (dates) =>
                  setState(() => _multiCount = dates.length),
            ),
          ),
          _section(
            '9 · Quick-range presets',
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final entry in NepaliDatePresets().labeled.entries)
                  ActionChip(
                    label: Text(entry.key),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                        '${entry.key}: ${entry.value.durationInDays} days',
                      )),
                    ),
                  ),
              ],
            ),
          ),
          _section(
            '10 · Age / duration + relative time',
            Builder(builder: (context) {
              final dob = const NepaliDate(2055, 3, 12);
              final age = NepaliAge.between(dob);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'DOB ${NepaliDateFormat('yyyy-MM-dd', widget.language).format(dob)}'),
                  Text('Age: $age'),
                  Text('Relative: '
                      '${NepaliRelativeTime.format(dob, language: widget.language)}'),
                ],
              );
            }),
          ),
          _section(
            '11 · BS date-time picker',
            Row(children: [
              FilledButton.tonal(
                onPressed: () async {
                  final dt = await showNepaliDateTimePicker(
                      context: context, language: widget.language);
                  if (dt != null) {
                    setState(() => _dateTime = dt);
                  }
                },
                child: const Text('Pick date + time'),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(_dateTime == null
                      ? 'None'
                      : NepaliDateFormat('yyyy-MM-dd HH:mm', widget.language)
                          .format(_dateTime!))),
            ]),
          ),
          _section(
            '12 · Type-to-enter / paste a BS date',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NepaliDateInputField(
                  language: widget.language,
                  onChanged: (d) => setState(() => _typed = d),
                ),
                const SizedBox(height: 8),
                Text(_typed == null
                    ? 'Parsed: -'
                    : 'Parsed: ${NepaliDateFormat('EEEE, MMMM d, y', widget.language).format(_typed!)}'),
              ],
            ),
          ),
          _section(
            '13 · Week view',
            NepaliWeekView(
              anchor: _weekAnchor,
              selected: _weekAnchor,
              language: widget.language,
              events: _events,
              onDateSelected: (d) => setState(() => _weekAnchor = d),
            ),
          ),
          _section(
            '14 · Activity heatmap',
            NepaliHeatmapCalendar(
              month: NepaliDateUtils.today(),
              language: widget.language,
              values: {
                NepaliDateUtils.today(): 5,
                NepaliDateUtils.today().add(const Duration(days: 1)): 2,
                NepaliDateUtils.today().subtract(const Duration(days: 3)): 8,
              },
            ),
          ),
          _section(
            '15 · Agenda view',
            NepaliAgendaView(
              events: _events,
              language: widget.language,
            ),
          ),
          _section(
            '16 · Researched holidays (BS 2082 - verify before official use)',
            NepaliCalendar(
              language: widget.language,
              initialDate: NepaliDate(2082, 7, 1),
              selectionMode: NepaliSelectionMode.none,
              events: NepaliHolidays.toEvents(
                candidateHolidaysForYear(2082),
                fromYear: 2082,
                toYear: 2082,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Demonstrates the raw BS ⇄ AD conversion API in both directions.
///
/// - **BS → AD**: pick a Bikram Sambat date, then `bs.toDateTime()`.
/// - **AD → BS**: pick a Gregorian date, then `ad.toNepaliDate()`
///   (a `DateTime` extension provided by the package engine).
class DateConverterSection extends StatefulWidget {
  /// Creates the converter demo.
  const DateConverterSection({super.key, required this.language});

  /// Active language for formatting the output.
  final Language language;

  @override
  State<DateConverterSection> createState() => _DateConverterSectionState();
}

class _DateConverterSectionState extends State<DateConverterSection> {
  NepaliDate _bs = NepaliDate.now();
  DateTime _ad = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final DateTime bsAsAd = _bs.toDateTime();
    final NepaliDate adAsBs = _ad.toNepaliDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('BS → AD', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            OutlinedButton.icon(
              icon: const Icon(Icons.event),
              label: Text(
                NepaliDateFormat('yyyy-MM-dd', widget.language).format(_bs),
              ),
              onPressed: () async {
                final picked = await showNepaliDatePicker(
                  context: context,
                  initialDate: _bs,
                  firstDate: NepaliDate(kNckMinBsYear),
                  lastDate: NepaliDate(kNckMaxBsYear),
                  language: widget.language,
                );
                if (picked != null) setState(() => _bs = picked);
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, size: 18),
            ),
            Expanded(
              child: Text(
                '${bsAsAd.year}-${_two(bsAsAd.month)}-${_two(bsAsAd.day)} AD',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('AD → BS', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            OutlinedButton.icon(
              icon: const Icon(Icons.public),
              label: Text('${_ad.year}-${_two(_ad.month)}-${_two(_ad.day)}'),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _ad,
                  firstDate: DateTime(1944),
                  lastDate: DateTime(2043),
                );
                if (picked != null) setState(() => _ad = picked);
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, size: 18),
            ),
            Expanded(
              child: Text(
                '${NepaliDateFormat('yyyy-MM-dd', widget.language).format(adAsBs)} BS',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
