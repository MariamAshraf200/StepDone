import 'package:StepDone/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'time_field.dart';

class TimeRangeField extends StatefulWidget {
  const TimeRangeField({
    super.key,
    this.readOnly = false,
    this.canBeNull = false,
    this.startTime,
    this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  final bool readOnly;
  final bool canBeNull;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final void Function(TimeOfDay? start) onStartTimeChanged;
  final void Function(TimeOfDay? end) onEndTimeChanged;

  @override
  State<TimeRangeField> createState() => _TimeRangeFieldState();
}

class _TimeRangeFieldState extends State<TimeRangeField> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _endTimeError;

  @override
  void initState() {
    super.initState();
    _startTime = widget.startTime;
    _endTime = widget.endTime;
  }

  // مقارنة الوقت بالدقائق
  bool _isEndBeforeStart(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes < startMinutes;
  }

  void _handleStartTime(TimeOfDay selectedStart) {
    setState(() {
      _startTime = selectedStart;
      _endTimeError = null;
    });
    widget.onStartTimeChanged(selectedStart);
  }

  void _handleEndTime(TimeOfDay selectedEnd) {
    final l10n = context.l10n;
    if (_startTime != null && _isEndBeforeStart(_startTime!, selectedEnd)) {
      setState(() => _endTimeError = l10n.endBeforeStart);
    } else {
      setState(() {
        _endTime = selectedEnd;
        _endTimeError = null;
      });
      widget.onEndTimeChanged(selectedEnd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🟣 العنوان
        Row(
          children: [
            // 🕒 Start Time
            Flexible(
              fit: FlexFit.loose,
              child: TimeField(
                labelText: l10n.timeFormat,
                outSideTitle: l10n.startTime,
                initialTime: _startTime,
                onTimeSelected: _handleStartTime,
                isRequired: true, // لا يمكن تركه فارغًا
                canBeNull: false,
              ),
            ),
            const SizedBox(width: 14),
            // ⏰ End Time
            Flexible(
              fit: FlexFit.loose,
              child: TimeField(
                labelText: l10n.timeFormat,
                outSideTitle: l10n.endTime,
                initialTime: _endTime,
                startTime: _startTime, // للمقارنة
                onTimeSelected: _handleEndTime,
                canBeNull: true,
                onValidationChanged: (err) => setState(() => _endTimeError = err),
              ),
            ),
          ],
        ),
        // Show end-time validation message full-width beneath the row (not a SnackBar)
        if (_endTimeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
            child: Text(
              _endTimeError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
