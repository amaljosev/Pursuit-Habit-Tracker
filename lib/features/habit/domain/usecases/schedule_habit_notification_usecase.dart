import 'package:pursuit/features/habit/domain/repositories/notification_repository.dart';

class ScheduleHabitNotificationUseCase {
  final NotificationRepository repository;

  ScheduleHabitNotificationUseCase(this.repository);

  Future<void> call({
    required int habitId,
    required String habitName,
    required DateTime reminderTime,
  }) {
    return repository.scheduleHabitNotification(
      id: habitId,
      title: habitName,
      scheduledAt: reminderTime,
    );
  }
}
