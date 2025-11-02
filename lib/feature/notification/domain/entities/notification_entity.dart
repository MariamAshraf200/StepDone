class AppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
  });
}
