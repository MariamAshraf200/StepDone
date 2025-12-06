import '../../domain/scheduled_reminder.dart';

abstract class ReminderState {}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class ReminderLoaded extends ReminderState {
  final List<ScheduledReminder> reminders;
  ReminderLoaded(this.reminders);
}

class ReminderError extends ReminderState {
  final String message;
  ReminderError(this.message);
}

