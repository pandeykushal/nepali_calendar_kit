/// A modern, Material 3 Bikram Sambat (BS) calendar & date picker toolkit for
/// Flutter.
///
/// Fully self-contained: BS↔AD conversion, the date type, formatting and all
/// widgets are the package's own code, with **no third-party runtime
/// dependency**. The conversion data lives in `lib/src/engine/bs_calendar_data.dart`.
library nepali_calendar_kit;

export 'src/engine/language.dart';
export 'src/engine/nepali_date.dart' show NepaliDate, NepaliDateFromDateTime;
export 'src/engine/nepali_date_format.dart';
export 'src/engine/nepali_date_names.dart';
export 'src/engine/bs_calendar_data.dart'
    show
        BsCalendarData,
        kBsMonthDataVerified,
        kAnchorBsYear,
        kAnchorBsMonth,
        kAnchorBsDay,
        kAnchorAdYear,
        kAnchorAdMonth,
        kAnchorAdDay;
export 'src/engine/bs_calendar_data_experimental.dart'
    show kBsMonthDataExperimental;
export 'src/engine/nepali_duration.dart';
export 'src/engine/nepali_relative_time.dart';
export 'src/engine/nepali_holidays.dart';
export 'src/engine/nepali_holidays_dataset.dart';

export 'src/core/date_range.dart';
export 'src/core/nepali_date_utils.dart'
    show NepaliDateUtils, kNckMinBsYear, kNckMaxBsYear;
export 'src/core/nepali_month_grid.dart';
export 'src/core/nepali_fiscal_year.dart';
export 'src/core/nepali_date_presets.dart';
export 'src/l10n/calendar_labels.dart';
export 'src/models/calendar_event.dart';
export 'src/models/selection_mode.dart';

export 'src/theme/nepali_calendar_theme.dart';

export 'src/widgets/calendar_builders.dart';
export 'src/widgets/combined_bs_ad_view.dart';
export 'src/widgets/cupertino_nepali_date_picker.dart';
export 'src/widgets/nepali_agenda_view.dart';
export 'src/widgets/nepali_calendar.dart'
    show NepaliCalendar, NepaliRangeChanged;
export 'src/widgets/nepali_date_form_field.dart';
export 'src/widgets/nepali_date_input_field.dart';
export 'src/widgets/nepali_date_picker_dialog.dart';
export 'src/widgets/nepali_date_time_picker.dart';
export 'src/widgets/nepali_heatmap_calendar.dart';
export 'src/widgets/nepali_week_view.dart';
export 'src/widgets/show_nepali_date_picker.dart';
