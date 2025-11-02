import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<bool> scheduleNotification(AppNotification notification);

  Future<void> cancelNotification(int id);

  Future<void> showNow(AppNotification notification);

  Future<void> requestPermission();
}

