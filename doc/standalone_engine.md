# Standalone BS engine (removing the nepali_utils dependency)

The package is moving to its **own** Bikram Sambat engine so it has **zero
runtime dependency** on `nepali_utils`. This means no version conflicts for your
users, nothing to update when they publish, and full control over the supported
year range (including pre-1970 BS for family-tree / historical apps).

## How conversion works

BS↔AD conversion is pure **day-counting** over a table of month lengths from one
verified anchor date. The engine code is original; the **data** (month lengths)
is the thing that must be correct and comes from *your* source.

- `lib/src/engine/nepali_date.dart` — `NepaliDate` type + converter (done)
- `lib/src/engine/nepali_date_format.dart` — formatter (done)
- `lib/src/engine/nepali_date_names.dart` — month/weekday/digit data (done)
- `lib/src/engine/language.dart` — our own `Language` enum (done)
- `lib/src/engine/bs_calendar_data.dart` — verified table (1969–2250) + the
  `BsCalendarData` access class with the verified/experimental toggle
- `lib/src/engine/bs_calendar_data_experimental.dart` — opt-in, **unverified**
  pre-1969 table (1898–1968)

### Two data tiers

- **Verified (1969–2250)** — authoritative, always active.
- **Experimental (1898–1968)** — off by default; enable with
  `BsCalendarData.includeExperimental = true` for historical/genealogy apps.
  Unverified; absolute pre-1969 AD dates may be ~a day off at the seam, because
  the block was authored against a different 1969 boundary. Round-trips stay
  consistent and the verified range is unaffected either way.

The converter math is verified: every date in the table round-trips
BS→AD→BS with zero error.

## The Excel format I need

One row per BS year, first column the year, next 12 columns the month lengths
(Baisakh → Chaitra), every value 29–32, **contiguous years, no gaps**:

| BS Year | Baisakh | Jestha | Ashadh | Shrawan | Bhadra | Ashwin | Kartik | Mangsir | Poush | Magh | Falgun | Chaitra |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1969 | 31 | 31 | 31 | 32 | 31 | 31 | 30 | 29 | 30 | 29 | 30 | 30 |
| 1970 | … | | | | | | | | | | | |
| … | | | | | | | | | | | | |

Header names don't matter (columns are read by position); the data does.

## Generating the data file

```bash
pip install pandas openpyxl
python tool/generate_bs_data.py your_table.xlsx \
    --anchor-bs 2000-01-01 --anchor-ad 1943-04-14 \
    --out lib/src/engine/bs_calendar_data.dart
```

The **anchor** is one verified BS=AD pair inside your table. The generator
refuses to write if the table has gaps, a wrong month count, or out-of-range
day values — so a structural mistake can't silently ship.

After generating, run `flutter test` — `test/engine_converter_test.dart`
re-checks the table and round-trips every date, and you should add a couple of
real known-date anchors (e.g. `2080-01-01 BS == 2023-04-14 AD`) to lock
correctness.

## Switch-over status — DONE

As of v0.1.0 the dependency has been fully removed:

1. ✅ Widgets/pickers use `NepaliDate` (no more `NepaliDateTime`).
2. ✅ The barrel exports the engine and no longer re-exports `nepali_utils`.
3. ✅ `nepali_utils` removed from `pubspec.yaml` — zero runtime dependencies.
4. Run `flutter analyze` + `flutter test` after any data regeneration.

The converter is verified by round-tripping every date in the bundled table
(100k+) with zero mismatches, plus known anchors (`2080-01-01 BS =
2023-04-14 AD`, Gorkha quake `2072-01-12 BS = 2015-04-25 AD`).
