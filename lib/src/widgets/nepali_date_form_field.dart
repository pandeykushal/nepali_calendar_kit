import 'package:flutter/material.dart';
import '../engine/language.dart';
import '../engine/nepali_date.dart';
import '../engine/nepali_date_format.dart';

import '../core/nepali_date_utils.dart';
import '../theme/nepali_calendar_theme.dart';
import 'show_nepali_date_picker.dart';

/// A [FormField] that shows the selected BS date and opens
/// [showNepaliDatePicker] when tapped. Integrates with [Form] for validation
/// and saving.
///
/// Example:
/// ```dart
/// NepaliDateFormField(
///   decoration: const InputDecoration(labelText: 'Date of birth'),
///   firstDate: NepaliDate(2000),
///   lastDate: NepaliDate.now(),
///   validator: (d) => d == null ? 'Required' : null,
///   onSaved: (d) => _dob = d,
/// )
/// ```
class NepaliDateFormField extends FormField<NepaliDate> {
  /// Creates the form field.
  NepaliDateFormField({
    super.key,
    NepaliDate? initialValue,
    this.firstDate,
    this.lastDate,
    this.language,
    this.calendarTheme,
    this.pickerStyle = NepaliDatePickerStyle.adaptive,
    this.format,
    this.decoration = const InputDecoration(),
    this.enabled = true,
    this.hintText = 'Select date',
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    ValueChanged<NepaliDate?>? onChanged,
  }) : super(
          initialValue: initialValue,
          enabled: enabled,
          builder: (field) {
            final state = field as _NepaliDateFormFieldState;
            final value = field.value;
            final lang = language ?? Language.english;
            final text = value == null
                ? null
                : (format ?? NepaliDateFormat('yyyy-MM-dd', lang)).format(value);

            return InkWell(
              onTap: enabled ? () => state._openPicker(onChanged) : null,
              child: InputDecorator(
                decoration: decoration.copyWith(
                  errorText: field.errorText,
                  suffixIcon: const Icon(Icons.calendar_today),
                  enabled: enabled,
                ),
                isEmpty: value == null,
                child: Text(
                  text ?? hintText,
                  style: value == null
                      ? Theme.of(field.context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: Theme.of(field.context)
                                .hintColor,
                          )
                      : Theme.of(field.context).textTheme.bodyLarge,
                ),
              ),
            );
          },
        );

  /// Earliest selectable date.
  final NepaliDate? firstDate;

  /// Latest selectable date.
  final NepaliDate? lastDate;

  /// Active language.
  final Language? language;

  /// Calendar visual overrides passed to the picker.
  final NepaliCalendarTheme? calendarTheme;

  /// Which picker style to open.
  final NepaliDatePickerStyle pickerStyle;

  /// How to render the chosen date in the field. Defaults to `yyyy-MM-dd`.
  final NepaliDateFormat? format;

  /// Field decoration.
  final InputDecoration decoration;

  /// Whether the field is interactive.
  final bool enabled;

  /// Placeholder shown when nothing is selected.
  final String hintText;

  @override
  FormFieldState<NepaliDate> createState() => _NepaliDateFormFieldState();
}

class _NepaliDateFormFieldState extends FormFieldState<NepaliDate> {
  @override
  NepaliDateFormField get widget => super.widget as NepaliDateFormField;

  Future<void> _openPicker(ValueChanged<NepaliDate?>? onChanged) async {
    final picked = await showNepaliDatePicker(
      context: context,
      initialDate: value ?? NepaliDateUtils.today(),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      style: widget.pickerStyle,
      language: widget.language,
      theme: widget.calendarTheme,
    );
    if (picked != null) {
      didChange(picked);
      onChanged?.call(picked);
    }
  }
}
