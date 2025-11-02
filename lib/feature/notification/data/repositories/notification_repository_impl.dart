import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasource/local_notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final LocalNotificationService localService;

  NotificationRepositoryImpl(this.localService);

  @override
  Future<bool> scheduleNotification(AppNotification notification) {
    return localService.scheduleNotification(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      time: notification.scheduledTime,
    );
  }

  @override
  Future<void> cancelNotification(int id) => localService.cancel(id);

  @override
  Future<void> showNow(AppNotification notification) =>
      localService.showNow(notification.id, notification.title, notification.body);

  @override
  Future<void> requestPermission() => localService.requestPermission();
}
