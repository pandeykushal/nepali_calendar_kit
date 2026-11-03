# nepali_calendar_kit

[![pub package](https://img.shields.io/pub/v/nepali_calendar_kit.svg)](https://pub.dev/packages/nepali_calendar_kit)
[![pub points](https://img.shields.io/pub/points/nepali_calendar_kit)](https://pub.dev/packages/nepali_calendar_kit/score)
[![likes](https://img.shields.io/pub/likes/nepali_calendar_kit)](https://pub.dev/packages/nepali_calendar_kit/score)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-blue)](https://pub.dev/packages/nepali_calendar_kit)

A modern Bikram Sambat (BS) calendar and date picker toolkit for Flutter.

It has its own BS/AD conversion engine, so it does not depend on any other
package at runtime. On top of that it gives you a themeable Material 3 calendar,
adaptive pickers, range and multi-date selection, event markers, a form field,
and helpers like age, relative time and fiscal year.

## Features

- BS to AD and AD to BS conversion, built in (no third party dependency)
- Month grid engine you can use without any widgets
- Inline calendar widget, Material 3, light and dark
- `showNepaliDatePicker()` that adapts to the platform (Material dialog on
  Android, Cupertino wheel on iOS)
- Single, range and multiple date selection
- Minimum/maximum dates and arbitrary disabled dates
- Event / tithi / holiday markers, with holiday and weekend highlighting
- Custom day and header builders
- Combined BS and AD live view
- `NepaliDateFormField` and a type-to-enter / paste text field
- Date and time picker
- Formatting and parsing (ASCII or Devanagari digits)
- Age and duration, relative time (aaja / hijo), fiscal year and quarter,
  quick range presets
- Agenda, week and heatmap views
- Nepali and English, with Devanagari numerals
- Works on all six platforms and is WASM ready

## Supported range

The verified data covers **1969 to 2250 BS** and is always on. An optional
experimental range extends back to **1898 BS** for historical and genealogy
apps. It is off by default and is not independently verified, so turn it on only
if you need it:

```dart
BsCalendarData.includeExperimental = true;
```

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  nepali_calendar_kit: ^0.2.0
```

Then import it:

```dart
import 'package:nepali_calendar_kit/nepali_calendar_kit.dart';
```

## Usage

### Convert between BS and AD

```dart
final ad = NepaliDate(2081, 7, 17).toDateTime();   // BS -> DateTime
final bs = DateTime(2024, 11, 2).toNepaliDate();    // AD -> NepaliDate
final nowBs = NepaliDate.now();
```

### Show a date picker

```dart
final date = await showNepaliDatePicker(
  context: context,
  initialDate: NepaliDate.now(),
  firstDate: NepaliDate(2075),
  lastDate: NepaliDate(2090),
  language: Language.nepali,
);
```

### Pick a range

```dart
final range = await showNepaliDateRangePicker(context: context);
print(range?.durationInDays);
```

### Inline calendar with markers

```dart
NepaliCalendar(
  language: Language.nepali,
  showAdDate: true,
  events: {
    NepaliDate(2081, 7, 3): const [
      CalendarEvent(title: 'Dashain', isHoliday: true),
    ],
  },
  onDateChanged: (date) => print(date),
)
```

### Form field

```dart
NepaliDateFormField(
  decoration: const InputDecoration(labelText: 'Date of birth'),
  firstDate: NepaliDate(2000),
  lastDate: NepaliDate.now(),
  validator: (d) => d == null ? 'Required' : null,
  onSaved: (d) => _dob = d,
)
```

### Format and parse

```dart
final text = NepaliDateFormat('yyyy-MM-dd', Language.nepali)
    .format(NepaliDate(2081, 7, 3));          // २०८१-०७-०३

final back = NepaliDate.parse('2081-07-03');   // also accepts Devanagari
```

### Helpers

```dart
final age = NepaliAge.between(NepaliDate(2055, 3, 12));   // 26 years, ...
final ago = NepaliRelativeTime.format(NepaliDate(2081, 7, 1));

final fy = NepaliFiscalYear.of(NepaliDate.now());         // 2081/82
final thisWeek = NepaliDatePresets().thisWeek;            // a NepaliDateRange
```

### Theming

Colors and text styles follow your app theme by default. Override only what you
need:

```dart
NepaliCalendar(
  theme: NepaliCalendarTheme(
    selectedDayBackgroundColor: Colors.teal,
    todayBorderColor: Colors.teal,
  ),
)
```

### Headless engine

The grid and date math have no Flutter dependency, so they are easy to test:

```dart
final grid = NepaliMonthGrid(2081, 7);
grid.days;              // 42 cells, week starts Sunday
grid.daysInMonth;
NepaliDateUtils.addMonths(NepaliDate(2081, 12, 1), 2);
```

See the `example/` app for every feature in one place.

## Holidays

Festival dates in Nepal are mostly lunar and change every year, so the package
ships the mechanism plus a researched starter set for BS 2081 and 2082. Treat it
as reference data and verify before using it for anything official.

```dart
final events = NepaliHolidays.toEvents(
  candidateHolidaysForYear(2082),
  fromYear: 2082,
  toYear: 2082,
);
```

For production, supply your own maintained list through `NepaliHoliday.on(...)`
and `NepaliHoliday.fixed(...)`.

## Additional information

- Conversion is day counting over a bundled month length table from a single
  verified anchor (1 Baisakh 1970 BS = 13 April 1913 AD).
- Issues and pull requests are welcome on the repository.

## License

MIT. See the [LICENSE](LICENSE) file.
