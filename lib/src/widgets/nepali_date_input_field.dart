import 'package:flutter/material.dart';

import '../engine/language.dart';
import '../engine/nepali_date.dart';
import '../theme/nepali_calendar_theme.dart';
import 'show_nepali_date_picker.dart';

/// A text field where the user can **type or paste** a BS date
/// (`yyyy-MM-dd`, ASCII or Devanagari digits), with a button to open the
/// calendar picker instead.
///
/// Calls [onChanged] with the parsed [NepaliDate], or null while the text is
/// empty or not yet a valid date.
class NepaliDateInputField extends StatefulWidget {
  /// Creates the input field.
  const NepaliDateInputField({
    super.key,
    this.initialValue,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.language,
    this.calendarTheme,
    this.decoration = const InputDecoration(
      labelText: 'BS date (yyyy-mm-dd)',
      border: OutlineInputBorder(),
    ),
    this.enablePicker = true,
  });

  /// Pre-filled value.
  final NepaliDate? initialValue;

  /// Earliest acceptable date (validation + picker bound).
  final NepaliDate? firstDate;

  /// Latest acceptable date (validation + picker bound).
  final NepaliDate? lastDate;

  /// Fired on every change with the parsed date (null if incomplete/invalid).
  final ValueChanged<NepaliDate?>? onChanged;

  /// Language for the picker.
  final Language? language;

  /// Theme for the picker.
  final NepaliCalendarTheme? calendarTheme;

  /// Field decoration (a suffix calendar icon is added when [enablePicker]).
  final InputDecoration decoration;

  /// Whether to show a button that opens the calendar picker.
  final bool enablePicker;

  @override
  State<NepaliDateInputField> createState() => _NepaliDateInputFieldState();
}

class _NepaliDateInputFieldState extends State<NepaliDateInputField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue == null ? '' : _fmt(widget.initialValue!),
  );

  String _fmt(NepaliDate d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String? _error;

  void _handle(String text) {
    if (text.trim().isEmpty) {
      setState(() => _error = null);
      widget.onChanged?.call(null);
      return;
    }
    final parsed = NepaliDate.tryParse(text);
    if (parsed == null) {
      setState(() => _error = 'Invalid date');
      widget.onChanged?.call(null);
      return;
    }
    if (widget.firstDate != null && parsed.isBefore(widget.firstDate!)) {
      setState(() => _error = 'Before earliest allowed date');
      widget.onChanged?.call(null);
      return;
    }
    if (widget.lastDate != null && parsed.isAfter(widget.lastDate!)) {
      setState(() => _error = 'After latest allowed date');
      widget.onChanged?.call(null);
      return;
    }
    setState(() => _error = null);
    widget.onChanged?.call(parsed);
  }

  Future<void> _openPicker() async {
    final picked = await showNepaliDatePicker(
      context: context,
      initialDate: NepaliDate.tryParse(_controller.text),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      language: widget.language,
      theme: widget.calendarTheme,
    );
    if (picked != null) {
      _controller.text = _fmt(picked);
      _handle(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.datetime,
      onChanged: _handle,
      decoration: widget.decoration.copyWith(
        errorText: _error,
        suffixIcon: widget.enablePicker
            ? IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _openPicker,
                tooltip: 'Open calendar',
              )
            : null,
      ),
    );
  }
}
