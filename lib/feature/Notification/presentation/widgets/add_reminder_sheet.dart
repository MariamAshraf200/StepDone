import 'package:StepDone/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/util/date_and_time/date_format_util.dart';
import '../cubit/reminder_cubit.dart';

class AddReminderSheet extends StatefulWidget {
  const AddReminderSheet({Key? key}) : super(key: key);

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final TextEditingController _textController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // 0 == daily, otherwise number of hours (1,3,6,9,12)
  // Stored as a single integer so the UI and cubit consume a simple value.
  int _selectedHours = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Returns the combined DateTime built from the selected date and time.
  /// If the user didn't pick a date or time, the missing part(s) default to
  /// the current date/time so the method always returns a DateTime.
  DateTime _getCombined() {
    final now = DateTime.now();

    // Use selected date if available, otherwise default to today's date.
    final date = _selectedDate ?? now;

    // Use selected time if available, otherwise default to current time.
    final tod = _selectedTime ?? TimeOfDay.fromDateTime(now);

    return DateTime(
      date.year,
      date.month,
      date.day,
      tod.hour,
      tod.minute,
    );
  }

  /// Delegates to the core date formatter so all formatting is centralized.
  String _formatDate(DateTime dt) => DateFormatUtil.formatDateAndTimeCompact(dt);

  /// Shows the platform date and time pickers and stores the chosen values
  /// into state. The sheet will re-render when both are selected.
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  /// Builds the header title of the sheet.
  Widget _buildHeader(ColorScheme scheme) {
    return Text(
      context.l10n.createReminder,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: scheme.onSurface,
      ),
    );
  }

  /// Builds the title input TextField.
  Widget _buildTitleInput(ColorScheme scheme) {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: context.l10n.reminderTitle,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }

  /// Builds the date/time picker button which opens native pickers when
  /// tapped. The label shows the selected date/time when available.
  Widget _buildDateTimePicker(ColorScheme scheme) {
    return ElevatedButton.icon(
      onPressed: () async => await _pickDateTime(),
      icon: const Icon(Icons.calendar_month_rounded),
      label: Text(
        // _getCombined() now always returns a DateTime (defaults missing parts to now)
        _formatDate(_getCombined()),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Builds the repeat options list.
  ///
  /// The list is intentionally simple: a `ListTile` for 'Daily' and a
  /// few `ListTile`s for hourly choices. We use leading icons to mimic radio
  /// behavior so this avoids the deprecated RadioListTile API.
  Widget _buildRepeatOptions(ColorScheme scheme) {
    // simple vertical list
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Daily
          ListTile(
            leading: Icon(
              _selectedHours == 0
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: _selectedHours == 0 ? scheme.primary : null,
            ),
            title: Text(context.l10n.daily),
            onTap: () => setState(() => _selectedHours = 0),
          ),
          const Divider(height: 4),
          // Hourly options
          ...[1, 3, 6, 9, 12].map((h) {
            final selected = _selectedHours == h;
            return ListTile(
              leading: Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? scheme.primary : null,
              ),
              // Use compact localized hour label (e.g. '1h' or Arabic '1س')
              title: Text(context.l10n.hoursShort(h)),
              subtitle: Text(context.l10n.everyHours(h)),
              onTap: () => setState(() => _selectedHours = h),
            );
          }),
        ],
      ),
    );
  }

  /// Builds the confirm button. When pressed it validates inputs and calls
  /// `ReminderCubit.scheduleReminder(...)` passing `hoursInterval` or null
  /// when daily is chosen.
  Widget _buildConfirmButton(ColorScheme scheme) {
    final cubit = context.read<ReminderCubit>();
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle_outline),
        label: Text(context.l10n.confirm),
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          final text = _textController.text.trim();
          final first = _getCombined();
          // We default missing date/time parts to `now`, so only validate title.
          if (text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.pleaseFillAllFields)),
            );
            return;
          }
          // Map UI selection to the cubit parameter: `null` indicates daily
          // repetition; otherwise pass the selected number of hours.
          final hours = _selectedHours == 0 ? null : _selectedHours;

          cubit.scheduleReminder(
              text: text, firstDateTime: first, hoursInterval: hours);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildHeader(scheme),
            const SizedBox(height: 14),
            _buildTitleInput(scheme),
            const SizedBox(height: 12),
            _buildDateTimePicker(scheme),
            const SizedBox(height: 10),
            _buildRepeatOptions(scheme),
            const SizedBox(height: 16),
            _buildConfirmButton(scheme),
          ],
        ),
      ),
    );
  }
}
