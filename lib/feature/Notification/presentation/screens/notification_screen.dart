import 'package:StepDone/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/reminder_cubit.dart';
import '../cubit/reminder_state.dart';
import '../widgets/notification_header.dart';
import '../widgets/reminder_card.dart';
import '../widgets/notification_empty.dart';
import '../widgets/add_reminder_sheet.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => ReminderCubit(),
      child: Builder(
        builder: (context) => Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAddSheet(context),
            icon: const Icon(Icons.add_alarm_rounded),
            label: Text(context.l10n.addReminder),
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
          ),
          body: SafeArea(
            child: BlocBuilder<ReminderCubit, ReminderState>(
              builder: (context, state) {
                final cubit = context.read<ReminderCubit>();
                final reminders = state is ReminderLoaded
                    ? state.reminders
                    : cubit.reminders;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotificationHeader(count: reminders.length),
                    Expanded(
                      child: reminders.isEmpty
                          ? const NotificationEmpty()
                          : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: reminders.length,
                          itemBuilder: (context, index) {
                            final r = reminders[index];
                            return ReminderCard(reminder: r, index: index);
                          },
                        ),
                      ),
                    ),

                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ReminderCubit>(),
        child: AddReminderSheet(),
      ),
    );
  }
}
