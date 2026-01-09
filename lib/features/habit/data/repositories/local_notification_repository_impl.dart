import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:pursuit/features/habit/domain/repositories/notification_repository.dart';

class LocalNotificationRepositoryImpl implements NotificationRepository {
  final FlutterLocalNotificationsPlugin _plugin;

  LocalNotificationRepositoryImpl(this._plugin);

  @override
  Future<void> init() async {
    initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  @override
  Future<void> scheduleHabitNotification({
    required int id,
    required String title,
    required DateTime scheduledAt,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      'Time to complete your habit',
      tz.TZDateTime.from(scheduledAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_channel',
          'Habit Reminders',
          importance: Importance.max,
          priority: Priority.high
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      
    );
  }

  @override
  Future<void> cancelHabitNotification(int id) {
    return _plugin.cancel(id);
  }
}
