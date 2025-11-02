import '../repositories/notification_repository.dart';

class RequestPermissionUseCase {
  final NotificationRepository repo;
  RequestPermissionUseCase(this.repo);
  Future<void> call() => repo.requestPermission();
}
