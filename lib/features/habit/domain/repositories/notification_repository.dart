abstract class NotificationRepository {
  Future<void> init();

  Future<void> scheduleHabitNotification({
    required int id,
    required String title,
    required DateTime scheduledAt,
  });

  Future<void> cancelHabitNotification(int id);
}
