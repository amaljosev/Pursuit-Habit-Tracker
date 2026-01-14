import 'package:pursuit/features/habit/domain/repositories/notification_repository.dart';

class CancelAllHabitNotificationsUseCase {
  final NotificationRepository repository;

  CancelAllHabitNotificationsUseCase(this.repository);

  Future<void> call() async {
    await repository.cancelAll();
  }
}
