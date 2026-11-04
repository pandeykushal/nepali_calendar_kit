## 0.2.0

- Added date parsing: `NepaliDate.parse`/`tryParse` and `NepaliDateFormat.parse`.
- Added multiple (non-contiguous) date selection.
- Added a date and time picker and a type-to-enter / paste field.
- Added helpers: age and duration, relative time, fiscal year and quarter,
  and quick range presets.
- Added agenda, week and heatmap views.
- Added holiday auto-highlight and animated month transitions.
- Added a holiday mechanism and a researched starter dataset for BS 2081 and 2082.
- Split the data into a verified range (1969 to 2250) and an optional
  experimental range (1898 to 1968).
- Made all BS/AD conversion UTC based so results are stable across time zones.

## 0.1.0

- First release with the BS calendar engine, inline calendar, adaptive pickers,
  range selection, markers, theming, localization and a form field.
  