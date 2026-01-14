import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:pursuit/features/habit/domain/repositories/notification_repository.dart';

class LocalNotificationRepositoryImpl implements NotificationRepository {
  final FlutterLocalNotificationsPlugin _plugin;

  LocalNotificationRepositoryImpl(this._plugin);

  @override
  Future<void> init() async {
    initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),

      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings);
  }

  @override
Future<void> scheduleHabitNotification({
  required int id,
  required String title,
  required DateTime scheduledAt,
}) async {
  final tz.TZDateTime scheduledDate = _nextInstanceOfTime(scheduledAt);
  
  // Check exact alarm permission status
  bool canScheduleExact = true;
  if (defaultTargetPlatform == TargetPlatform.android) {
    final status = await Permission.scheduleExactAlarm.status;
    canScheduleExact = status.isGranted;
  }

  await _plugin.zonedSchedule(
    id,
    title,
    'Time to complete your habit',
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_channel',
        'Habit Reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    // Use exact alarms if permission is granted
    androidScheduleMode: canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

  @override
  Future<void> cancelHabitNotification(int id) {
    return _plugin.cancel(id);
  }

  

  tz.TZDateTime _nextInstanceOfTime(DateTime dateTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled = tz.TZDateTime.from(dateTime, tz.local);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
  
  @override
  Future<void> cancelAll() async{
    await _plugin.cancelAll();
  }
}
