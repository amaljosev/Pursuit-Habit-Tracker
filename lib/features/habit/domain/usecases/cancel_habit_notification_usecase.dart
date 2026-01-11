import 'package:pursuit/features/habit/domain/repositories/notification_repository.dart';

class CancelHabitNotificationUseCase {
  final NotificationRepository repository;

  CancelHabitNotificationUseCase(this.repository);

  Future<void> call(int habitId) {
    return repository.cancelHabitNotification(habitId);
  }
}
