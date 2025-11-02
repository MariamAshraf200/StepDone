import '../repositories/notification_repository.dart';

class CancelNotificationUseCase {
  final NotificationRepository repo;
  CancelNotificationUseCase(this.repo);
  Future<void> call(int id) => repo.cancelNotification(id);
}

