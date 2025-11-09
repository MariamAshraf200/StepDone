class ScheduledReminder {
  final String text;
  final DateTime dateTime;
  final int daysInterval;
  final List<int> ids;

  const ScheduledReminder({
    required this.text,
    required this.dateTime,
    required this.daysInterval,
    required this.ids,
  });
}
