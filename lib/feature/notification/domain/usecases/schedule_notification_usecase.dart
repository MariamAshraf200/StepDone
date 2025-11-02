import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class ScheduleNotificationUseCase {
  final NotificationRepository repo;
  ScheduleNotificationUseCase(this.repo);
  Future<bool> call(AppNotification notification) =>
      repo.scheduleNotification(notification);
}
