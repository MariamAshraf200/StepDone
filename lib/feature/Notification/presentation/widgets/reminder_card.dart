import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/util/date_and_time/date_format_util.dart';
import '../../domain/scheduled_reminder.dart';
import '../cubit/reminder_cubit.dart';

class ReminderCard extends StatelessWidget {
  final ScheduledReminder reminder;
  final int index;

  const ReminderCard({super.key, required this.reminder, required this.index});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReminderCubit>();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        children: [
          // Left Icon Section
          Container(
            decoration: BoxDecoration(
              color: scheme.primary.withAlpha((0.12 * 255).round()),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.alarm_rounded, color: scheme.primary),
          ),

          const SizedBox(width: 14),

          // Middle Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '⏰ ${DateFormatUtil.formatDateAndTimeShort(reminder.dateTime)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right Delete Button
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: scheme.error, size: 22),
            onPressed: () => cubit.cancelReminder(index),
          ),
        ],
      ),
    );
  }
}
