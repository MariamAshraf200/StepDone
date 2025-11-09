import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/reminder_cubit.dart';
import 'package:mapperapp/l10n/l10n_extension.dart';

class AddReminderSheet extends StatefulWidget {
  const AddReminderSheet({Key? key}) : super(key: key);

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _nDaysController = TextEditingController(text: '3');
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _everyNDays = false;

  @override
  void dispose() {
    _textController.dispose();
    _nDaysController.dispose();
    super.dispose();
  }

  DateTime? _getCombined() {
    if (_selectedDate == null || _selectedTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cubit = context.read<ReminderCubit>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Header
          Text(
            context.l10n.createReminder,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),

          // Title input
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: context.l10n.reminderTitle,
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: scheme.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date/time picker
          ElevatedButton.icon(
            onPressed: () async => await _pickDateTime(),
            icon: const Icon(Icons.calendar_month_rounded),
            label: Text(
              _getCombined() != null ? _formatDate(_getCombined()!) : context.l10n.pickDateTime,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),

          // Repeat options
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FilterChip(
                label: Text(context.l10n.daily),
                selected: !_everyNDays,
                onSelected: (_) => setState(() => _everyNDays = false),
                selectedColor: scheme.primaryContainer,
                backgroundColor: scheme.surface,
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: Text(context.l10n.everyNDays),
                selected: _everyNDays,
                onSelected: (_) => setState(() => _everyNDays = true),
                selectedColor: scheme.primaryContainer,
                backgroundColor: scheme.surface,
              ),
              if (_everyNDays)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _nDaysController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: context.l10n.nLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Confirm
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: Text(context.l10n.confirm),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final text = _textController.text.trim();
                final first = _getCombined();
                if (text.isEmpty || first == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.pleaseFillAllFields)),
                  );
                  return;
                }
                final days = _everyNDays ? int.tryParse(_nDaysController.text) ?? 1 : 1;

                cubit.scheduleReminder(text: text, firstDateTime: first, daysInterval: days);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
